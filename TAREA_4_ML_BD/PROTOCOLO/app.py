import os

import joblib
import numpy as np
import pandas as pd
import streamlit as st
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

# ------------------------------------------------------------------
# Configuración general
# ------------------------------------------------------------------
st.set_page_config(page_title="Tiempos de Espera en Sala", page_icon="🏥", layout="wide")
st.title("🏥 Panel Operativo de Tiempos de Espera en Sala")
st.caption("Red de clínicas Salud Integral · Apoyo a la decisión para jefes de sede")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Los modelos viven en ../DATOS; si no existe, se buscan junto a app.py
DATA_DIR = os.path.join(BASE_DIR, "..", "DATOS")
if not os.path.isdir(DATA_DIR):
    DATA_DIR = BASE_DIR
UMBRAL_ALERTA = 20       # minutos: por encima se emite alerta roja
MARGEN_PRECAUCION = 5    # minutos bajo el umbral que se consideran "precaución"
DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
ARCHIVOS_MODELOS = {
    "Lasso": "modelo_espera_lasso.joblib",
    "SVR": "modelo_espera_svr.joblib",
    "GradientBoosting": "modelo_espera_gbr.joblib",
}


@st.cache_resource
def cargar_artefactos():
    modelos = {n: joblib.load(os.path.join(DATA_DIR, a)) for n, a in ARCHIVOS_MODELOS.items()}
    meta = joblib.load(os.path.join(DATA_DIR, "metadata_espera.joblib"))
    return modelos, meta


@st.cache_data(ttl=600)
def cargar_historico(url_bd):
    url = url_bd
    if url.startswith("postgres://"):
        url = url.replace("postgres://", "postgresql://", 1)
    if url.startswith("postgresql://"):
        url = url.replace("postgresql://", "postgresql+psycopg2://", 1)
    engine = create_engine(url)
    consulta = (
        "SELECT c.fecha_hora, c.es_telemedicina, c.duracion_min, c.tiempo_espera_min, co.sede, co.piso "
        "FROM citas c INNER JOIN consultorios co ON c.id_consultorio = co.id_consultorio"
    )
    return pd.read_sql(consulta, con=engine)


try:
    modelos, meta = cargar_artefactos()
except FileNotFoundError as e:
    st.error(f"No se encontró un archivo del modelo ({e}). Ejecuta primero la Fase 3 del cuaderno.")
    st.stop()


# ------------------------------------------------------------------
# Reglas de negocio: de la predicción numérica a la acción
# ------------------------------------------------------------------
def nivel_alerta(espera):
    if espera > UMBRAL_ALERTA:
        return "🔴 ROJA"
    if espera > UMBRAL_ALERTA - MARGEN_PRECAUCION:
        return "🟡 PRECAUCIÓN"
    return "🟢 NORMAL"


def mostrar_decision(espera):
    if espera > UMBRAL_ALERTA:
        st.error(
            f"ALERTA ROJA: espera estimada de {espera:.1f} min (umbral: {UMBRAL_ALERTA} min). "
            "Acción sugerida: reasignar el paciente a un consultorio con menor carga o ampliar el intervalo entre citas."
        )
    elif espera > UMBRAL_ALERTA - MARGEN_PRECAUCION:
        st.warning(
            f"PRECAUCIÓN: espera estimada de {espera:.1f} min, cercana al umbral de {UMBRAL_ALERTA} min. "
            "Acción sugerida: monitorear la sala y evitar sobreagendar esta franja."
        )
    else:
        st.success(f"NORMAL: espera estimada de {espera:.1f} min. Acción sugerida: mantener la agenda.")


def construir_casos(sede, piso, dia, horas, duracion, experiencia, telemedicina):
    # Una fila por hora; los escalares se repiten. Mismas columnas con las que se entrenó el pipeline.
    return pd.DataFrame({
        "piso": int(piso),
        "hora": list(horas),
        "dia_semana": DIAS.index(dia),
        "duracion_min": int(duracion),
        "anios_experiencia": float(experiencia),
        "sede": sede,
        "es_telemedicina": int(telemedicina),
    })[meta["features"]]


def predecir(modelo, X):
    return np.clip(modelo.predict(X), 0, None)


def centrar(rango, referencia):
    return min(max(referencia, rango[0]), rango[1])


# ------------------------------------------------------------------
# Barra lateral
# ------------------------------------------------------------------
st.sidebar.header("Navegación")
opcion = st.sidebar.radio("Selecciona un módulo:", [
    "1. Simulador de espera por cita",
    "2. Carga horaria de la jornada",
    "3. Monitor histórico por sede",
])

nombres_modelos = list(modelos.keys())
modelo_ref = st.sidebar.selectbox(
    "Modelo de referencia para la alerta:", nombres_modelos, index=nombres_modelos.index(meta["mejor_modelo"])
)
met = {m["Modelo"]: m for m in meta["metricas"]}[modelo_ref]
st.sidebar.markdown(
    f"**Desempeño en prueba ({modelo_ref})**  \n"
    f"MAE: {met['MAE']:.2f} min · RMSE: {met['RMSE']:.2f} min · R²: {met['R2']:.3f}"
)
if met["R2"] < 0.10:
    st.sidebar.warning(
        "El poder explicativo del modelo es bajo (R² cercano a 0). "
        "Usa la estimación como orientación, no como un valor exacto."
    )

dur_min, dur_max = meta["duracion_min"]
exp_min, exp_max = meta["anios_experiencia"]

# ------------------------------------------------------------------
# Módulo 1: simulador de espera por cita
# ------------------------------------------------------------------
if opcion.startswith("1."):
    st.subheader("🔮 Simulador de tiempo de espera para una cita")
    c1, c2 = st.columns(2)
    with c1:
        sede = st.selectbox("Sede:", meta["sedes"])
        piso = st.selectbox("Piso:", meta["pisos"])
        dia = st.selectbox("Día de la semana:", DIAS)
        hora = st.slider("Hora de la cita (24 h):", 0, 23, 10)
    with c2:
        duracion = st.slider("Duración planificada (min):", dur_min, dur_max, int(centrar((dur_min, dur_max), 30)))
        experiencia = st.slider(
            "Años de experiencia del médico:", exp_min, exp_max, round((exp_min + exp_max) / 2, 1), step=0.1
        )
        telemedicina = st.checkbox("¿Es consulta por telemedicina?")

    if st.button("Estimar tiempo de espera"):
        # Bloque de inferencia: armar el caso, predecir con los 3 modelos y decidir
        X_caso = construir_casos(sede, piso, dia, [hora], duracion, experiencia, telemedicina)
        predicciones = {n: float(predecir(m, X_caso)[0]) for n, m in modelos.items()}
        espera = predicciones[modelo_ref]

        m1, m2 = st.columns(2)
        m1.metric(
            f"Espera estimada ({modelo_ref})", f"{espera:.1f} min",
            delta=f"{espera - UMBRAL_ALERTA:+.1f} min vs umbral", delta_color="inverse",
        )
        m2.metric("Nivel de alerta", nivel_alerta(espera))
        st.progress(float(min(espera / (2 * UMBRAL_ALERTA), 1.0)))
        mostrar_decision(espera)

        st.markdown("**Predicción de los 3 modelos**")
        tabla = pd.DataFrame({
            "Modelo": list(predicciones.keys()),
            "Espera estimada (min)": [round(v, 1) for v in predicciones.values()],
            "Alerta": [nivel_alerta(v) for v in predicciones.values()],
        })
        st.dataframe(tabla, hide_index=True)
        st.caption("Si los modelos discrepan o quedan cerca del umbral, la decisión debe apoyarse en el criterio del jefe de sede.")

# ------------------------------------------------------------------
# Módulo 2: carga horaria de la jornada
# ------------------------------------------------------------------
elif opcion.startswith("2."):
    st.subheader("📈 Simulación de la carga horaria de la jornada")
    c1, c2 = st.columns(2)
    with c1:
        sede = st.selectbox("Sede:", meta["sedes"])
        piso = st.selectbox("Piso:", meta["pisos"])
        dia = st.selectbox("Día de la semana:", DIAS)
        rango = st.slider("Franja de la jornada (horas):", 0, 23, (7, 19))
    with c2:
        duracion = st.slider("Duración planificada (min):", dur_min, dur_max, int(centrar((dur_min, dur_max), 30)))
        experiencia = st.slider(
            "Años de experiencia del médico:", exp_min, exp_max, round((exp_min + exp_max) / 2, 1), step=0.1
        )
        telemedicina = st.checkbox("¿Consultas por telemedicina?")

    if st.button("Simular jornada"):
        # Bloque de inferencia: una predicción por hora con cada modelo
        horas = list(range(rango[0], rango[1] + 1))
        X_dia = construir_casos(sede, piso, dia, horas, duracion, experiencia, telemedicina)
        curvas = pd.DataFrame({"Hora": horas})
        for nombre, modelo in modelos.items():
            curvas[nombre] = predecir(modelo, X_dia)
        curvas["Umbral de alerta"] = UMBRAL_ALERTA
        st.line_chart(curvas.set_index("Hora"))

        rojas = curvas.loc[curvas[modelo_ref] > UMBRAL_ALERTA, "Hora"].tolist()
        k1, k2, k3 = st.columns(3)
        k1.metric("Franjas simuladas", len(horas))
        k2.metric("Franjas en alerta roja", len(rojas))
        k3.metric("Pico de espera (min)", f"{curvas[modelo_ref].max():.1f}")

        if rojas:
            st.error(
                f"ALERTA ROJA en {len(rojas)} de {len(horas)} franjas ({modelo_ref}): "
                + ", ".join(f"{h:02d}:00" for h in rojas)
                + ". Acción sugerida: reasignar consultorios o ampliar el intervalo entre citas en esas franjas."
            )
        else:
            st.success("Ninguna franja supera el umbral de 20 minutos. Acción sugerida: mantener la agenda.")

        st.markdown(f"**Comparativo entre sedes (espera estimada, {modelo_ref})**")
        comparativo = pd.DataFrame({"Hora": horas})
        for s in meta["sedes"]:
            X_s = construir_casos(s, piso, dia, horas, duracion, experiencia, telemedicina)
            comparativo[s] = predecir(modelos[modelo_ref], X_s)
        st.dataframe(comparativo.set_index("Hora").round(1))

# ------------------------------------------------------------------
# Módulo 3: monitor histórico por sede (datos reales en Neon)
# ------------------------------------------------------------------
else:
    st.subheader("📊 Monitor histórico de espera por sede")
    url_bd = os.getenv("DATABASE_URL_ESTUDIANTE")
    if not url_bd:
        st.error("DATABASE_URL_ESTUDIANTE no está configurada en el archivo .env.")
        st.stop()

    df = cargar_historico(url_bd).copy()
    df["sede"] = df["sede"].astype(str).str.strip().str.title()
    df["hora"] = pd.to_datetime(df["fecha_hora"]).dt.hour
    df = df[df["tiempo_espera_min"].between(0, 120)]

    resumen = (
        df.groupby("sede")["tiempo_espera_min"]
        .agg(citas="size", espera_media="mean", pct_sobre_umbral=lambda s: (s > UMBRAL_ALERTA).mean() * 100)
        .round(1)
        .reset_index()
    )
    st.dataframe(resumen, hide_index=True)

    peor = resumen.sort_values("pct_sobre_umbral", ascending=False).iloc[0]
    st.info(
        f"{peor['sede']} tiene la mayor proporción de citas con espera sobre {UMBRAL_ALERTA} min "
        f"({peor['pct_sobre_umbral']:.1f} %)."
    )

    st.markdown("**Espera media por sede (min)**")
    st.bar_chart(resumen.set_index("sede")["espera_media"])
    st.markdown("**Espera media por hora del día (min)**")
    st.line_chart(df.groupby("hora")["tiempo_espera_min"].mean())

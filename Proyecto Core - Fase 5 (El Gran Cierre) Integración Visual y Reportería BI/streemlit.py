import streamlit as st
import pandas as pd
import pyodbc

# ==========================================================
# 1. Conexión Segura (Driver 18 con flags probados y usuario no-sa)
# ==========================================================
conn_str = (
    'DRIVER={ODBC Driver 18 for SQL Server};'
    'SERVER=localhost,1433;'
    'DATABASE=CrediCore;'
    'UID=usr_cajero;'
    'PWD=PasswordSeguro2026!;'
    'Encrypt=no;'
    'TrustServerCertificate=yes'
)

st.set_page_config(
    page_title="ERP CrediCore - Módulo de Caja", 
    page_icon="🏦", 
    layout="wide"
)

st.title("🏦 CrediCore - Módulo de Caja")
st.markdown("Interfaz operativa conectada al motor transaccional de SQL Server")

# ==========================================================
# 2. Consulta a la Vista Segura (Abstracción total de tablas base)
# ==========================================================
st.subheader("📋 Estado de Cuenta (Vista Segura)")

try:
    conn = pyodbc.connect(conn_str)
    # Consumo exclusivo de la vista de atención al cliente
    query = "SELECT * FROM Operaciones.vw_AtencionAlCliente"
    df = pd.read_sql(query, conn)
    st.dataframe(df, use_container_width=True)
    st.metric(label="Total de Créditos en Cartera", value=len(df))
except Exception as e:
    st.error(f"Error de conexión o lectura en la base de datos: {e}")

st.divider()

# ==========================================================
# 3. Formulario Transaccional (Consumo del SP_ProcesarPago)
# ==========================================================
st.subheader("💳 Procesar Pago de Cuota")

with st.form("form_pago", clear_on_submit=True):
    col1, col2 = st.columns(2)
    with col1:
        id_credito = st.number_input("Número de Crédito (ID)", min_value=1, step=1)
    with col2:
        monto_pago = st.number_input("Monto a Abonar (Q)", min_value=1.0, step=100.0, format="%.2f")
    
    btn_pagar = st.form_submit_button("Ejecutar Transacción")
    
    if btn_pagar:
        try:
            # Reutilizamos o abrimos conexión para ejecutar el SP
            cursor = conn.cursor()
            cursor.execute(
                f"EXEC Operaciones.SP_ProcesarPago @IdCredito = {id_credito}, @MontoAbono = {monto_pago}"
            )
            conn.commit()
            st.success(f"¡Pago de Q{monto_pago:,.2f} procesado con éxito en SQL Server para el crédito #{id_credito}!")
            st.rerun()  # Recarga la vista para reflejar la reducción de saldo
        except Exception as e:
            # Captura del RAISERROR / THROW originado en el bloque TRY...CATCH de SQL Server
            st.error(f"Transacción Rechazada por el Motor:\n\n{e}")
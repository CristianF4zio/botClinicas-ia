# Flujo conversacional — Bot Clínica Ejemplo

Este documento describe la lógica que el workflow de n8n debe implementar
(la implementación visual se arma manualmente en n8n; esto es la referencia).

## Datos de la "Clínica Ejemplo" (ficticios, para el demo)

- Nombre: Clínica Ejemplo
- Dirección: Av. Francisco de Miranda, Chacao, Caracas
- Horario: Lunes a viernes 7:00 am – 6:00 pm, sábados 8:00 am – 12:00 m
- Especialidades: Medicina general, Pediatría, Ginecología, Cardiología, Dermatología
- Precio consulta general: 30 USD (o su equivalente en bolívares a tasa del día)
- Precio consulta especialista: 45 USD
- Formas de pago: efectivo (USD/Bs), Zelle, transferencia, punto de venta

Estos datos viven como referencia para el system prompt y para las respuestas
automáticas de preguntas frecuentes. En un despliegue real reemplazan datos
reales de la clínica.

## 1. Saludo inicial

Al llegar el primer mensaje de un contacto nuevo (o de un contacto sin
actividad reciente), el bot se presenta y pregunta el motivo de contacto:

> "¡Hola! 👋 Soy el asistente virtual de Clínica Ejemplo. ¿En qué te puedo
> ayudar hoy? Por ejemplo: agendar una cita, conocer nuestros horarios o
> precios, o hablar con alguien del equipo."

A partir de la respuesta, el bot clasifica la intención en una de estas
cuatro rutas.

## 2. Ruta: agendar cita

1. Pregunta especialidad deseada (si no la mencionó ya).
2. Pregunta fecha y horario preferido.
3. Pregunta nombre completo del paciente (si es la primera vez que escribe).
4. Resume los datos capturados y pide confirmación explícita ("¿Confirmas
   la cita de Pediatría el martes 24 a las 10:00 am?").
5. Al confirmar, el workflow guarda la cita en la base `clinica` (tabla
   `citas`) y responde con un mensaje de confirmación final, incluyendo
   qué traer (cédula, referencia médica si aplica).
6. Si el paciente pide cambiar o cancelar, se repite el mismo patrón de
   captura + confirmación sobre la cita existente.

Nota: el bot no verifica disponibilidad real contra una agenda en este
demo; en producción este paso se conecta a un calendario o sistema de
turnos.

## 3. Ruta: pregunta frecuente

Si la intención es horario, ubicación, especialidades o precio de
consulta, el bot responde directamente con la información de la sección
"Datos de la Clínica Ejemplo" de arriba, sin inventar nada adicional.

Si la pregunta frecuente no está cubierta por esos datos (por ejemplo,
"¿aceptan tal seguro?"), el bot lo trata como fuera de alcance (ruta 4).

## 4. Ruta: fuera de alcance

Disparadores típicos: preguntas médicas (diagnóstico, dosis, síntomas
específicos), reclamos, temas administrativos no cubiertos, o cualquier
cosa que el bot no pueda responder con la información que tiene.

El bot responde algo como:

> "Eso lo puede resolver mejor una persona del equipo. Ya le aviso para
> que continúe esta conversación contigo. 🙌"

Y el workflow marca la conversación para atención humana (por ejemplo,
un flag en la tabla `conversaciones` o una notificación a un canal
interno), sin intentar responder la pregunta original.

## Persistencia

Toda conversación (mensaje entrante, respuesta del bot, intención
detectada) se guarda en la base `clinica` para tener historial y poder
darle seguimiento humano cuando haga falta. Las citas confirmadas se
guardan en una tabla separada con estado (pendiente/confirmada/cancelada).

El diseño de las tablas (`citas`, `conversaciones`) se define al armar el
workflow en n8n; este documento cubre la lógica conversacional, no el
esquema de base de datos.

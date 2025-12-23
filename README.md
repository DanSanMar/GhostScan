# 👻 GhostScan v1.6 - Ghost Protocol (ACK Mode)

<p align="center">
  <img width="602" height="417" alt="GhostScan Banner" src="https://github.com/user-attachments/assets/6ad9359c-bfcd-4a26-8ee2-47b5255f1388" />
</p>

---

### 📖 Descripción
**GhostScan** es un script de automatización en Bash diseñado para el **descubrimiento sigiloso y la auditoría táctica** de redes locales. Utiliza el *Protocolo Ghost (Modo ACK)* para evadir firewalls corporativos que bloquean paquetes SYN convencionales, permitiendo identificar hosts activos mediante la simulación de respuestas a conexiones preexistentes.

---

## 🚀 Características Principales

* **Ofuscación de Identidad:** Cambio automático de dirección MAC antes de iniciar cualquier escaneo mediante `macchanger`.
* **Evasión de Firewall (ACK Mode):** Utiliza sondas TCP ACK (`-PA`) para atravesar firewalls con estado (stateful) que filtran intentos de conexión nuevos.
* **Análisis Táctico con Nmap:**
    * Uso de señuelos (`-D RND:10`) para ocultar la IP del atacante.
    * Fragmentación de paquetes (`-f`) y puertos de origen falsificados (`--source-port 53`).
    * Sincronización **T2 (Polite)** para reducir el ruido en los sistemas de detección de intrusos (IDS).
* **Motor de Categorización Inteligente:** Clasifica automáticamente los dispositivos en:
    * 🖨️ Impresoras / Multifuncionales.
    * 🌐 Servidores Web / Aplicaciones (Apache, Nginx, IIS).
    * 🛡️ Infraestructura de Red (Cisco, MikroTik, Gateways).
* **Auditoría de Vulnerabilidades:** Integración con scripts de Nmap para detectar riesgos críticos y factores de riesgo alto.
* **Reporte Ejecutivo:** Genera un informe de ciberinteligencia limpio y sin códigos de color ANSI directamente en el escritorio del usuario.

---

## 🛠️ Requisitos

El script requiere las siguientes herramientas instaladas en un sistema Linux (preferiblemente **Kali Linux** o **Parrot OS**):

| Herramienta | Función |
| :--- | :--- |
| `nmap` | Motor de escaneo y detección |
| `macchanger` | Ofuscación de dirección física |
| `iproute2` | Gestión de interfaces (comando ip) |
| `Sudo/Root` | Privilegios elevados para inyección de paquetes |

---

## 🛡️ Funcionamiento Técnico

El script opera en cuatro fases para garantizar la efectividad y el sigilo:

1.  **Capa de Invisibilidad:** Desactiva la interfaz de red y genera una MAC aleatoria.
2.  **Descubrimiento ACK:** Envía paquetes con el flag ACK activado a puertos comunes (80, 443, 445, 22, 161). Si el host responde con un RST, se confirma que está "Vivo".
3.  **Auditoría de Inteligencia:** Escanea servicios y busca vulnerabilidades conocidas solo en los objetivos detectados.
4.  **Generación de Reporte:** Consolida los hallazgos en un archivo `.txt`.

---

## ⚠️ Descargo de Responsabilidad

> [!IMPORTANT]
> Este script ha sido creado exclusivamente con fines educativos y de auditoría ética. El uso de esta herramienta contra objetivos sin autorización previa es ilegal. El desarrollador no se hace responsable del mal uso de este software.

---

## 🤝 Contribuciones

Si deseas mejorar el motor de categorización o añadir nuevas sondas de evasión, ¡eres bienvenido!

1.  Haz un **Fork** del proyecto.
2.  Crea una rama para tu mejora:  
    `git checkout -b feature/MejoraGhost`
3.  Haz un **Commit** de tus cambios:  
    `git commit -m 'Añadida nueva firma de detección'`
4.  Haz un **Push** a la rama:  
    `git push origin feature/MejoraGhost`
5.  Abre un **Pull Request**.

---
<p align="center">
  Desarrollado bajo el Protocolo Ghost. 👻
</p>

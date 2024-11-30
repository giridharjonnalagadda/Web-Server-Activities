# How can I create a real-time web dashboard using ESP32 to monitor data from multiple sensors (DHT11, Gas Sensor, and LDR) and display the readings (temperature, humidity, gas levels, and light intensity) using interactive gauges on a webpage?

#include <WiFi.h>
#include <WebServer.h>
#include <DHT.h>
 
// WiFi credentials
const char* ssid = "Act";
const char* password = "Madhumakeskilled";
 
// Pin definitions
#define DHT_PIN 4
#define GAS_SENSOR_PIN 34  // Analog pin for gas sensor
#define LDR_PIN 35        // Analog pin for LDR
 
// Initialize DHT sensor
#define DHTTYPE DHT11
DHT dht(DHT_PIN, DHTTYPE);
 
// Create web server object
WebServer server(80);
 
// Variables to store sensor readings
float temperature;
float humidity;
int gasValue;
int lightValue;
 
void setup() {
  Serial.begin(115200);
  // Initialize sensors
  dht.begin();
  pinMode(GAS_SENSOR_PIN, INPUT);
  pinMode(LDR_PIN, INPUT);
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  // Setup server routes
  server.on("/", handleRoot);
  server.on("/data", handleData);
  // Start server
  server.begin();
}
 
void loop() {
  server.handleClient();
  updateSensorReadings();
  delay(2000);  // Update every 2 seconds
}
 
void updateSensorReadings() {
  // Read DHT11 sensor
  temperature = dht.readTemperature();
  humidity = dht.readHumidity();
  // Read gas sensor
  gasValue = analogRead(GAS_SENSOR_PIN);
  // Read LDR sensor
  lightValue = analogRead(LDR_PIN);
}
 
void handleRoot() {
  String html = generateHTML();
  server.send(200, "text/html", html);
}
 
void handleData() {
  String json = "{";
  json += "\"temperature\":" + String(temperature) + ",";
  json += "\"humidity\":" + String(humidity) + ",";
  json += "\"gas\":" + String(gasValue) + ",";
  json += "\"light\":" + String(lightValue);
  json += "}";
  server.send(200, "application/json", json);
}
 
String generateHTML() {
  String html = R"(
<!DOCTYPE html>
<html>
<head>
<title>ESP32 Sensor Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://cdnjs.cloudflare.com/ajax/libs/gauge.js/1.3.7/gauge.min.js"></script>
<style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                margin: 0;
                padding: 20px;
                background: #f0f2f5;
            }
            .dashboard {
                max-width: 1200px;
                margin: 0 auto;
            }
            h1 {
                color: #2c3e50;
                text-align: center;
                margin-bottom: 40px;
                font-size: 2.5em;
            }
            .sensors-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 20px;
                margin-top: 20px;
            }
            .sensor-card {
                background: white;
                border-radius: 15px;
                padding: 20px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                text-align: center;
                transition: transform 0.3s ease;
            }
            .sensor-card:hover {
                transform: translateY(-5px);
            }
            .sensor-title {
                color: #34495e;
                font-size: 1.2em;
                margin-bottom: 15px;
                font-weight: 600;
            }
            .canvas-wrapper {
                position: relative;
                height: 200px;
            }
            .value-display {
                position: absolute;
                bottom: 20px;
                width: 100%;
                text-align: center;
                font-size: 1.8em;
                font-weight: bold;
                color: #2c3e50;
            }
            .unit {
                font-size: 0.5em;
                color: #7f8c8d;
            }
</style>
</head>
<body>
<div class="dashboard">
<h1>ESP32 Sensor Dashboard</h1>
<div class="sensors-grid">
<div class="sensor-card">
<div class="sensor-title">Temperature</div>
<div class="canvas-wrapper">
<canvas id="tempGauge"></canvas>
<div class="value-display">
<span id="temperature">--</span>
<span class="unit">°C</span>
</div>
</div>
</div>
<div class="sensor-card">
<div class="sensor-title">Humidity</div>
<div class="canvas-wrapper">
<canvas id="humidityGauge"></canvas>
<div class="value-display">
<span id="humidity">--</span>
<span class="unit">%</span>
</div>
</div>
</div>
<div class="sensor-card">
<div class="sensor-title">Gas Level</div>
<div class="canvas-wrapper">
<canvas id="gasGauge"></canvas>
<div class="value-display">
<span id="gas">--</span>
<span class="unit">ppm</span>
</div>
</div>
</div>
<div class="sensor-card">
<div class="sensor-title">Light Level</div>
<div class="canvas-wrapper">
<canvas id="lightGauge"></canvas>
<div class="value-display">
<span id="light">--</span>
<span class="unit">lux</span>
</div>
</div>
</div>
</div>
</div>
 
        <script>
            // Configure gauges
            const gaugeOptions = {
                angle: 0.15,
                lineWidth: 0.44,
                radiusScale: 1,
                pointer: {
                    length: 0.6,
                    strokeWidth: 0.035,
                    color: '#000000'
                },
                limitMax: false,
                limitMin: false,
                colorStart: '#6FADCF',
                colorStop: '#8FC0DA',
                strokeColor: '#E0E0E0',
                generateGradient: true,
                highDpiSupport: true,
                percentColors: [[0.0, "#63D471"], [0.50, "#FED766"], [1.0, "#EF476F"]]
            };
 
            // Initialize gauges
            const tempGauge = new Gauge(document.getElementById("tempGauge")).setOptions(
                {...gaugeOptions, maxValue: 50, minValue: 0}
            );
            const humidityGauge = new Gauge(document.getElementById("humidityGauge")).setOptions(
                {...gaugeOptions, maxValue: 100, minValue: 0}
            );
            const gasGauge = new Gauge(document.getElementById("gasGauge")).setOptions(
                {...gaugeOptions, maxValue: 4095, minValue: 0}
            );
            const lightGauge = new Gauge(document.getElementById("lightGauge")).setOptions(
                {...gaugeOptions, maxValue: 4095, minValue: 0}
            );
 
            // Set initial values
            tempGauge.maxValue = 50;
            tempGauge.setMinValue(0);
            tempGauge.animationSpeed = 32;
            tempGauge.set(0);
 
            humidityGauge.maxValue = 100;
            humidityGauge.setMinValue(0);
            humidityGauge.animationSpeed = 32;
            humidityGauge.set(0);
 
            gasGauge.maxValue = 4095;
            gasGauge.setMinValue(0);
            gasGauge.animationSpeed = 32;
            gasGauge.set(0);
 
            lightGauge.maxValue = 4095;
            lightGauge.setMinValue(0);
            lightGauge.animationSpeed = 32;
            lightGauge.set(0);
 
            function updateData() {
                fetch('/data')
                    .then(response => response.json())
                    .then(data => {
                        // Update gauges
                        tempGauge.set(data.temperature);
                        humidityGauge.set(data.humidity);
                        gasGauge.set(data.gas);
                        lightGauge.set(data.light);
 
                        // Update text displays
                        document.getElementById('temperature').textContent = data.temperature.toFixed(1);
                        document.getElementById('humidity').textContent = data.humidity.toFixed(1);
                        document.getElementById('gas').textContent = data.gas;
                        document.getElementById('light').textContent = data.light;
                    });
            }
            // Update every 2 seconds
            setInterval(updateData, 2000);
            // Initial update
            updateData();
</script>
</body>
</html>
  )";
  return html;
}
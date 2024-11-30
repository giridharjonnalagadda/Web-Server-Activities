# Develop a web-based application using an ESP32 microcontroller to monitor soil moisture levels dynamically. The application should display:

# Moisture Value Graph: A real-time line graph of the last 60 raw moisture readings from the soil moisture sensor.
# Moisture Percentage Graph: A real-time line graph of the last 60 calculated moisture percentages.

getting moisture graph and moisture percentage dynamically

#include <WiFi.h>
#include <WebServer.h>

// Replace with your Wi-Fi credentials
const char* ssid = "Act";
const char* password = "Madhumakeskilled";

// Create a web server object on port 80
WebServer server(80);

// Define analog pin for the soil moisture sensor
const int sensorPin = 34; // Use GPIO 34 or any other ADC pin

// Arrays to hold moisture value and percentage readings for one minute
int moistureValues[60];  // For raw moisture values
float moisturePercentages[60];  // For calculated moisture percentages
int sensorIndex = 0;  // Global index for storing readings

void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Serve the main HTML page with styling
  server.on("/", HTTP_GET, []() {
    String html = "<html><head>";
    html += "<script src='https://cdn.jsdelivr.net/npm/chart.js'></script>";
    html += "<style>";
    html += "body { font-family: 'Arial', sans-serif; background: #f4f6f9; margin: 0; padding: 20px; display: flex; justify-content: center; }";
    html += ".dashboard { display: flex; justify-content: space-around; gap: 20px; width: 100%; max-width: 1200px; }";
    html += ".card { background: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); padding: 20px; text-align: center; flex: 0 0 48%; min-width: 300px; }";
    html += ".card h2 { font-size: 1.5em; color: #34495e; margin-bottom: 10px; }";
    html += "button { background-color: #3498db; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; font-size: 1em; margin-bottom: 20px; }";
    html += "button:hover { background-color: #2980b9; }";
    html += "canvas { max-width: 100%; height: 300px; }";
    html += "@media (max-width: 768px) { .dashboard { flex-direction: column; align-items: center; } }"; // Stack on smaller screens
    html += "</style>";
    html += "</head><body>";
    html += "<div class='dashboard'>";
    html += "<div class='card'>";
    html += "<h2>Moisture Value</h2>";
    html += "<button onclick='getMoistureValueGraph()'>Show Moisture Value Graph</button>";
    html += "<canvas id='moistureValueGraph'></canvas>";
    html += "</div>";
    html += "<div class='card'>";
    html += "<h2>Moisture Percentage</h2>";
    html += "<button onclick='getMoisturePercentageGraph()'>Show Moisture Percentage Graph</button>";
    html += "<canvas id='moisturePercentageGraph'></canvas>";
    html += "</div>";
    html += "</div>";
    html += "<script>";
    html += "let moistureValueChart = null;";
    html += "let moisturePercentageChart = null;";

    // Fetch and display Moisture Value Graph
    html += "function getMoistureValueGraph() {";
    html += "  fetch('/getMoistureValues').then(response => response.json()).then(data => {";
    html += "    const ctx = document.getElementById('moistureValueGraph').getContext('2d');";
    html += "    if (moistureValueChart) moistureValueChart.destroy();";
    html += "    moistureValueChart = new Chart(ctx, {";
    html += "      type: 'line',";
    html += "      data: {";
    html += "        labels: Array.from({ length: 60 }, (_, i) => i + 1),";
    html += "        datasets: [{";
    html += "          label: 'Moisture Value (Raw)',";
    html += "          data: data.moistureValues,";
    html += "          borderColor: '#3498db',";
    html += "          fill: false";
    html += "        }]";
    html += "      },";
    html += "      options: {";
    html += "        scales: { x: { title: { display: true, text: 'Time (s)' } }, y: { title: { display: true, text: 'Moisture Value' } } }";
    html += "      }";
    html += "    });";
    html += "  });";
    html += "}";

    // Fetch and display Moisture Percentage Graph
    html += "function getMoisturePercentageGraph() {";
    html += "  fetch('/getMoisturePercentages').then(response => response.json()).then(data => {";
    html += "    const ctx = document.getElementById('moisturePercentageGraph').getContext('2d');";
    html += "    if (moisturePercentageChart) moisturePercentageChart.destroy();";
    html += "    moisturePercentageChart = new Chart(ctx, {";
    html += "      type: 'line',";
    html += "      data: {";
    html += "        labels: Array.from({ length: 60 }, (_, i) => i + 1),";
    html += "        datasets: [{";
    html += "          label: 'Moisture Percentage (%)',";
    html += "          data: data.moisturePercentages,";
    html += "          borderColor: '#1abc9c',";
    html += "          fill: false";
    html += "        }]";
    html += "      },";
    html += "      options: {";
    html += "        scales: { x: { title: { display: true, text: 'Time (s)' } }, y: { title: { display: true, text: 'Moisture Percentage' } } }";
    html += "      }";
    html += "    });";
    html += "  });";
    html += "}";
    html += "</script>";
    html += "</body></html>";
    server.send(200, "text/html", html);
  });

  // Return moisture values as JSON
  server.on("/getMoistureValues", HTTP_GET, []() {
    String json = "{\"moistureValues\":[";
    for (int i = 0; i < 60; i++) {
      json += String(moistureValues[i]);
      if (i < 59) json += ",";
    }
    json += "]}";
    server.send(200, "application/json", json);
  });

  // Return moisture percentages as JSON
  server.on("/getMoisturePercentages", HTTP_GET, []() {
    String json = "{\"moisturePercentages\":[";
    for (int i = 0; i < 60; i++) {
      json += String(moisturePercentages[i]);
      if (i < 59) json += ",";
    }
    json += "]}";
    server.send(200, "application/json", json);
  });

  // Start the server
  server.begin();
}

void loop() {
  unsigned long currentMillis = millis();
  static unsigned long previousMillis = 0;

  if (currentMillis - previousMillis >= 1000) {  // 1 second interval
    previousMillis = currentMillis;

    // Read the moisture sensor
    int moistureValue = analogRead(sensorPin);
    float moisturePercentage = map(moistureValue, 0, 4095, 0, 100);

    // Store the values in arrays
    moistureValues[sensorIndex] = moistureValue;
    moisturePercentages[sensorIndex] = moisturePercentage;

    // Increment index and reset after one minute (60 readings)
    sensorIndex = (sensorIndex + 1) % 60;

    // Print the values to Serial Monitor
    Serial.print("Moisture Value (Raw): ");
    Serial.print(moistureValue);
    Serial.print(" | Moisture Percentage: ");
    Serial.println(moisturePercentage);
  }

  server.handleClient();  // Handle incoming client requests
}
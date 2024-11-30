# How does the provided ESP32-based web server continuously update soil moisture sensor readings on a webpage without requiring a page refresh, and what are the advantages of this approach?


#include <WiFi.h>
#include <WebServer.h>

// Replace with your Wi-Fi credentials
const char* ssid = "Act";
const char* password = "Madhumakeskilled";

// Create a web server object on port 80
WebServer server(80);

// Define analog pin for the soil moisture sensor
const int sensorPin = 34; // Use GPIO 34 or any other ADC pin

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

  // Serve the main HTML page
  server.on("/", HTTP_GET, []() {
    String html = "<html><body>";
    html += "<h1>Soil Moisture Sensor</h1>";
    html += "<p id='moistureValue'>Moisture Value: Loading...</p>";
    html += "<p id='moisturePercentage'>Moisture Percentage: Loading...</p>";
    html += "<script>";
    html += "setInterval(function() {";
    html += "  fetch('/getMoisture').then(response => response.json()).then(data => {";
    html += "    document.getElementById('moistureValue').innerText = 'Moisture Value (Raw): ' + data.moistureValue;";
    html += "    document.getElementById('moisturePercentage').innerText = 'Soil Moisture (%): ' + data.percentage;";
    html += "  });";
    html += "}, 1000);";  // Refresh data every second (1000ms)
    html += "</script>";
    html += "</body></html>";
    server.send(200, "text/html", html);
  });

  // Serve the moisture data as JSON
  server.on("/getMoisture", HTTP_GET, []() {
    int moistureValue = analogRead(sensorPin); // Read soil moisture sensor value
    float percentage = map(moistureValue, 0, 4095, 0, 100); // Convert to percentage
    String json = "{\"moistureValue\":" + String(moistureValue) + ", \"percentage\":" + String(percentage) + "}";
    server.send(200, "application/json", json); // Send JSON response
  });
  
  // Start the server
  server.begin();
}

void loop() {
  server.handleClient(); // Handle client requests
}
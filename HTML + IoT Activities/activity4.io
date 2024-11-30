# Develop a web-based interface using ESP32 and the Wi-Fi module that interacts with a soil moisture sensor. The interface should provide two buttons:

# Get Moisture Value: Fetches and displays the raw soil moisture reading from the sensor.
# Get Moisture Percentage: Fetches and displays the calculated soil moisture percentage.


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

  // Serve the main HTML page with advanced styling
  server.on("/", HTTP_GET, []() {
    String html = "<html><head>";
    html += "<style>";
    html += "body { font-family: 'Arial', sans-serif; background: linear-gradient(45deg, #f0f4f8, #e0eaf1); display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;}";
    html += "h1 { color: #2980b9; text-align: center; font-size: 2.5em; text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.2);}";
    html += "p { color: #34495e; font-size: 1.4em; margin: 15px 0;}";
    html += ".container { background-color: #ffffff; padding: 40px 30px; border-radius: 15px; box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1); text-align: center; max-width: 400px; width: 100%; transition: transform 0.3s ease;}";
    html += ".container:hover { transform: translateY(-10px);}";
    html += "#moistureValue, #moisturePercentage { font-weight: bold; color: #16a085; font-size: 1.6em; transition: color 0.3s ease;}";
    html += "#moistureValue:hover, #moisturePercentage:hover { color: #1abc9c;}";
    html += "button { background-color: #3498db; color: white; padding: 12px 25px; border: none; border-radius: 30px; cursor: pointer; font-size: 1.1em; margin-top: 20px; transition: background-color 0.3s ease, transform 0.2s ease;}";
    html += "button:hover { background-color: #2980b9; transform: scale(1.1);}";
    html += "footer { margin-top: 40px; color: #7f8c8d; font-size: 1em; }";
    html += "@media (max-width: 600px) { h1 { font-size: 2em; } .container { padding: 20px; width: 90%; } }";
    html += "</style>";
    html += "</head><body>";
    html += "<div class='container'>";
    html += "<h1>Soil Moisture Sensor</h1>";
    html += "<p id='moistureValue'>Moisture Value: Loading...</p>";
    html += "<p id='moisturePercentage'>Moisture Percentage: Loading...</p>";
    
    // Two buttons to fetch different data
    html += "<button onclick='getMoistureValue()'>Get Moisture Value</button>";
    html += "<button onclick='getMoisturePercentage()'>Get Moisture Percentage</button>";
    
    html += "<footer>Powered by ESP32</footer>";
    html += "</div>";
    html += "<script>";
    // JavaScript to fetch moisture value
    html += "function getMoistureValue() {";
    html += "  fetch('/getMoistureValue').then(response => response.json()).then(data => {";
    html += "    document.getElementById('moistureValue').innerText = 'Moisture Value (Raw): ' + data.moistureValue;";
    html += "  });";
    html += "}";
    // JavaScript to fetch moisture percentage
    html += "function getMoisturePercentage() {";
    html += "  fetch('/getMoisturePercentage').then(response => response.json()).then(data => {";
    html += "    document.getElementById('moisturePercentage').innerText = 'Soil Moisture (%): ' + data.percentage;";
    html += "  });";
    html += "}";
    html += "</script>";
    html += "</body></html>";
    server.send(200, "text/html", html);
  });

  // Serve the moisture data as JSON for Moisture Value
  server.on("/getMoistureValue", HTTP_GET, []() {
    int moistureValue = analogRead(sensorPin); // Read soil moisture sensor value
    String json = "{\"moistureValue\":" + String(moistureValue) + "}";
    server.send(200, "application/json", json); // Send JSON response
  });

  // Serve the moisture percentage as JSON
  server.on("/getMoisturePercentage", HTTP_GET, []() {
    int moistureValue = analogRead(sensorPin); // Read soil moisture sensor value
    float percentage = map(moistureValue, 0, 4095, 0, 100); // Convert to percentage
    String json = "{\"percentage\":" + String(percentage) + "}";
    server.send(200, "application/json", json); // Send JSON response
  });
  
  // Start the server
  server.begin();
}

void loop() {
  server.handleClient(); // Handle client requests
}
# How can we display real-time soil moisture sensor data on a webpage using an ESP32, styled with CSS for a modern dashboard layout and using JavaScript to fetch and update data dynamically without refreshing the page?



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

  // Serve the main HTML page with styling
  server.on("/", HTTP_GET, []() {
    String html = "<html><head>";
    html += "<style>";
    html += "body { font-family: 'Arial', sans-serif; background-color: #f4f4f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;}";
    html += "h1 { color: #2c3e50; text-align: center; font-size: 2em; margin-bottom: 20px;}";
    html += "p { color: #34495e; font-size: 1.2em; margin: 10px 0;}";
    html += ".container { background-color: #fff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); text-align: center;}";
    html += "#moistureValue, #moisturePercentage { font-weight: bold; color: #1abc9c; font-size: 1.5em;}";
    html += "button { background-color: #3498db; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; font-size: 1em;}";
    html += "button:hover { background-color: #2980b9;}";
    html += "footer { margin-top: 30px; color: #7f8c8d; font-size: 0.9em; }";
    html += "</style>";
    html += "</head><body>";
    html += "<div class='container'>";
    html += "<h1>Soil Moisture Sensor</h1>";
    html += "<p id='moistureValue'>Moisture Value: Loading...</p>";
    html += "<p id='moisturePercentage'>Moisture Percentage: Loading...</p>";
    html += "<button onclick='window.location.reload()'>Refresh</button>";
    html += "<footer>Powered by ESP32</footer>";
    html += "</div>";
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
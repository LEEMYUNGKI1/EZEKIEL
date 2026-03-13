import base64
import os
import json
import urllib.request

api_key = os.environ.get('GEMINI_API_KEY')
if not api_key:
    print('No API Key found in environment variables.')
    exit(1)

file_path = r'f:\home\부서.jpg'
with open(file_path, 'rb') as f:
    img_data = base64.b64encode(f.read()).decode('utf-8')

url = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key={api_key}'

payload = {
  "contents": [
    {
      "parts": [
        {"text": "Please transcribe the organization chart in this image. Emphasize the hierarchy of departments (e.g., Board of Directors, CEO, and various teams). Do not include names and titles, just the department names and their hierarchical relationships."},
        {
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": img_data
          }
        }
      ]
    }
  ]
}

req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type': 'application/json'})
try:
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode())
        print(res['candidates'][0]['content']['parts'][0]['text'])
except Exception as e:
    print(f"Error: {e}")

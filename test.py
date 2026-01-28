import requests
import json

url = "https://xh.v1api.cc/v1/chat/completions"
headers = {
    "Authorization": "Bearer sk-Hoz53tcLZr740PsKG3nogboz5ETzcsbsdpihrjsXztAztBaF",
    "Content-Type": "application/json"
}

data = {
    "model": "gpt-4o-mini",
    "messages": [
        {
            "role": "user",
            "content": "你好！"
        }
    ],
    "stream": True
}

response = requests.post(url, headers=headers, json=data, stream=True)
print(f"Status Code: {response.content}")

if response.status_code == 200:
    print("\n=== Streaming Response ===")
    response.encoding = "utf-8"
    for line in response.iter_lines(decode_unicode=True):
        if line.strip():
            try:
                data = json.loads(line)
                if "choices" in data and data["choices"]:
                    delta = data["choices"][0].get("delta", {})
                    content = delta.get("content", "")
                    if content:
                        print(content, end="", flush=True)
            except json.JSONDecodeError:
                print(f"\n[Raw line]: {line}")
else:
    print(f"Error: {response.text}")
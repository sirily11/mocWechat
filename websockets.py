import asyncio

import boto3
import websockets

translate = boto3.client(service_name='translate', use_ssl=True)


async def time(websocket, path):
    while True:
        greeting = await websocket.recv()
        result = translate.translate_text(Text=greeting,                               SourceLanguageCode="en", TargetLanguageCode="zh")
        await asyncio.sleep(1)
        await websocket.send("You said: {}\n".format(result.get('TranslatedText')))


start_server = websockets.serve(time, '127.0.0.1', 5678)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

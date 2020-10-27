# https://medium.com/better-programming/how-to-create-a-websocket-in-python-b68d65dbd549


import asyncio
import logging
import websockets
# from websockets import WebSocketServerProtocol
import json
import drive_linear_motor as BedMotor

logging.basicConfig(level=logging.INFO)


class ENUM_MOTOR_STATE:
    up = 'up'
    stop = 'stop'
    down = 'down'


'''
Client-Message:
    {"action":"motor-control","command":"ld"}
'''


class Server:
    clients = set()
    state = {
        "left": ENUM_MOTOR_STATE.stop,
        "right": ENUM_MOTOR_STATE.stop,
        'by': '',
    }

    def run(self):
        # start_server = websockets.serve(self.ws_handler, "localhost", 6789)
        start_server = websockets.serve(self.ws_handler, "0.0.0.0", 6789)
        self.loop = asyncio.get_event_loop()
        self.loop.run_until_complete(start_server)
        self.loop.run_forever()

    # data {
    def state_data(self):
        # return json.dumps({"type": "state", *self.state: self.state.value})
        # return json.dumps({"type": "state", "value": self.state['value']})
        # return json.dumps({"type": "state", **self.state})
        return json.dumps({"type": "state", **self.state})

    def users_data(self):
        # return-users-count.
        return json.dumps({"type": "users", "count": len(self.clients)})
    # data }

    # action-notify {
    async def notify_state(self) -> None:
        if self.clients:  # asyncio.wait doesn't accept an empty list
            message = self.state_data()
            await asyncio.wait([client.send(message) for client in self.clients])

    async def notify_users(self) -> None:
        # print(self.clients)
        if self.clients:  # asyncio.wait doesn't accept an empty list
            message = self.users_data()
            await asyncio.wait([client.send(message) for client in self.clients])
    # action-notify }

    # action-connecting... {
    async def register(self, ws: websockets.WebSocketServerProtocol) -> None:
        # async def register(self, ws:WebSocketServerProtocol):
        self.clients.add(ws)
        # FIRST-CONNECTion รับข้อมูล ครั้งแรก
        self.state['by'] = 'first-time'
        await self.notify_state()
        await self.notify_users()
        logging.info(f'{ws.remote_address} connects.')
        # logging.info(self.users_data)

    async def unregister(self, ws: websockets.WebSocketServerProtocol) -> None:
        # ws_id = str(id(ws))
        # self.state['by'] = ws_id

        self.clients.remove(ws)
        await ws.close()
        # logging.info(self.users_data)
        
        # call stopAll motor
        HatMdd10.stopAll()

        self.state["right"] = ENUM_MOTOR_STATE.stop
        self.state["left"] = ENUM_MOTOR_STATE.stop
        self.state['by'] = 'disconnect'

        # เมื่อสั่ง Motor ให้บอกคนอื่นด้วย
        self.notify_state
    # action-connecting... }

    # action- return-message
    async def send_to_clients(self, message: str) -> None:
        if self.clients:
            await asyncio.wait([client.send(message) for client in self.clients])

    def loggingClientsCounter(self):
        if self.clients:
            return len(self.clients)

    # action- ws_handler
    async def ws_handler(self, ws: websockets.WebSocketServerProtocol, path: str):
        print('path: ' + path)
        print('start app_routes.')
        # register(websocket) sends user_event() to websocket
        await self.register(ws)
        logging.info(f'current ClientsCounter: {self.loggingClientsCounter()}')

        try:
            await self.app_routes(ws)
        except ValueError as e:
            logging.warning('Err message is not JSON-type.')
            logging.warning(f'more detail:{e}')
        finally:
            await self.unregister(ws)
            # บอกคนอื่นว่าออก
            await self.notify_users()

            # await websocket.close()

        logging.info(f'current ClientsCounter: {self.loggingClientsCounter()}')
        # clients_remaining = len(self.clients)
        # logging.info(f'clients remaining= |{clients_remaining}|')
        print('stop app_routes.')

    # action- app_routes-mapping
    async def app_routes(self, ws: websockets.WebSocketServerProtocol):
        # onConnected
        ws_id = str(id(ws))
        message_id = json.dumps({"type": "connection-id", "id": ws_id})
        await ws.send(message_id)
        # wait message-from-users
        async for message in ws:
            logging.info(f'debug ws_id: {ws_id}, show-data: {message}')
            # filter message-is-JSON with except-finally
            data = json.loads(message)
            # logging.info(f'debug show-data: {data}')
            # print(f'debug ws_id: {ws_id}, show-data: {data}')

            # require-action-mode
            if 'action' not in data:
                # raise ValueError("No 'command' in given data")
                # raise ValueError("'action' is Required.")
                logging.warning("'action' is Required.")
                break
            # mapping-actionu
            elif data["action"] == 'disconnect':
                # await ws.close()
                logging.info('action: disconnect')
                break
            elif data["action"] == 'motor-control':
                if 'command' not in data:
                    raise ValueError("No 'command' in given data")
                command = data["command"]
                # fixed(ใช้ connection-obj เป็น id): filter-data ถ้าไม่มี uuid ให้ close-connectของ-websocket
                if command == "ru":

                    HatMdd10.m1AB()
                    # message = 'm1AB'
                    self.state["right"] = ENUM_MOTOR_STATE.up
                    self.state['by'] = ws_id

                elif command == "rd":

                    HatMdd10.m1BA()
                    # message = 'm1BA'
                    self.state["right"] = ENUM_MOTOR_STATE.down
                    self.state['by'] = ws_id

                elif command == "r0":

                    HatMdd10.m1Is0()
                    # message = 'm1Is0'
                    self.state["right"] = ENUM_MOTOR_STATE.stop
                    self.state['by'] = ws_id

                # motor-2
                elif command == "lu":

                    HatMdd10.m2AB()
                    # message = 'm2AB'
                    self.state["left"] = ENUM_MOTOR_STATE.up
                    self.state['by'] = ws_id
                elif command == "ld":

                    HatMdd10.m2BA()
                    # message = 'm2BA'
                    self.state["left"] = ENUM_MOTOR_STATE.down
                    self.state['by'] = ws_id
                elif command == "l0":

                    HatMdd10.m2Is0()
                    # message = 'm2Is0'
                    self.state["left"] = ENUM_MOTOR_STATE.stop
                    self.state['by'] = ws_id

                elif command == "00":
                    # # Stop All L,R
                    HatMdd10.stopAll()
                    # message = 'stopAll'
                    self.state["right"] = ENUM_MOTOR_STATE.stop
                    self.state["left"] = ENUM_MOTOR_STATE.stop
                    self.state['by'] = ws_id

                else:
                    # return myRes({"dataStatus": "error", 'message': 'not command: ' + command}, 404)
                    # message = json.dumps(
                    #     {"type": "res", "dataStatus": 'error', 'message': 'not command: ' + command})
                    message = json.dumps(
                        {"type": "err", 'message': 'not command: ' + command})
                    await ws.send(message)

                    # # logging.error("unsupported event: {}", data)
                    # print("unsupported event: {}", data)

                await self.notify_state()


def main():
    # try:
    #     global HatMdd10
    #     # init driveMotor
    #     HatMdd10 = BedMotor.HatMdd10()
    #     app_api = Server()

    #     # ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)

    #     # cert = pathlib.Path(__file__).with_name("44048397_localhost.cert")
    #     # ca_cert = pathlib.Path(__file__).with_name("44048397_localhost.key")
    #     # ssl_context.load_cert_chain(cert, keyfile=ca_cert)

    #     # start--wss-Server
    #     # start_server = websockets.serve(app_routes, "127.0.0.1", 6789, ssl=ssl_context)
    #     # start_server = websockets.serve(
    #     #     app_routes, "127.0.0.1", 6789, ssl=ssl_context)
    #     # start_server = websockets.serve(app_routes, "127.0.0.1", 6789)
    #     # start_server = websockets.serve(app_api.ws_handler, "127.0.0.1", 6789)
    #     start_server = websockets.serve(app_api.ws_handler, "localhost", 6789)
    #     loop = asyncio.get_event_loop()
    #     loop.run_until_complete(start_server)
    #     loop.run_forever()

    #     # asyncio.get_event_loop().run_until_complete(start_server)
    #     # asyncio.get_event_loop().run_forever()
    # except Exception as err:
    #     print(str(err.args))
    # except:
    #     print('start-Server Err: server is Stoped.')
    # finally:
    #     # Fixed: stop slower 1.9s
    #     HatMdd10.stopAll()
    #     # clear driveMotor
    #     HatMdd10.cleanup()

    # # //not try
    # global HatMdd10
    # # init driveMotor
    # HatMdd10 = BedMotor.HatMdd10()
    # app_api = Server()
    # app_api.run()

    # HatMdd10.stopAll()
    # # clear driveMotor
    # HatMdd10.cleanup()

    # //with try
    try:
        global HatMdd10
        # init driveMotor
        HatMdd10 = BedMotor.HatMdd10()
        app_api = Server()
        app_api.run()
    except Exception as err:
        print('Exception is:')
        print(str(err.args))
    except KeyboardInterrupt:
        print("\n", "CTRL+C")
    else:
        print('some Err: server is Stoped.')
    finally:
        print('server has Stopping...')

        HatMdd10.stopAll()
        # clear driveMotor
        HatMdd10.cleanup()


if __name__ == '__main__':
    main()

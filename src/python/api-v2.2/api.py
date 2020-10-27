from flask import Flask, json, request
import drive_linear_motor as BedMotor
import threading
import time
import datetime

# Flask-Env:
# # on windows: set FLASK_APP=api.py
'''
on Linux: export FLASK_APP=api.py
on Linux: export FLASK_ENV=development

python3 api.py
'''

# run:
# # flask run
# # flask run --host=0.0.0.0

# NOTE: flask-API
#    # /stop //for Stop Server (ฉุกเฉิน)
#    # /api/{...}  [ru=1a,rd=1b,r0=10], [lu=2a,ld=2b,l0=20] //r0=right stop


# # (เวลา สำหรับหยุดมอเตอร์อัตโนมัติ)
LIMIT_MOTOR_RUNNING = 1.9  # Seconds

# หยุด Server
SESSION_NAME = ''
LAST_COMMAND = ''
LAST_PING_AT_TIME = 0


def shutdown_server():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()


def shutdown():
    shutdown_server()
    return 'Server shutting down...'


def create_app(HatMdd10):
    # https://flask.palletsprojects.com/en/1.1.x/tutorial/factory/
    app = Flask(__name__, static_url_path='', static_folder='dist',)

    # ทุกครั้ง Allow-Origin แก้ CORS
    @ app.after_request  # cors for Web-Browser
    def after_request(response):
        header = response.headers
        header['Access-Control-Allow-Origin'] = '*'
        return response

    # set response mimetype=JSON
    # บางครั้ง res-json
    # บางครั้ง res-html
    def myRes(data, headerStatus=200):
        response = app.response_class(
            response=json.dumps(data),
            status=headerStatus,
            mimetype='application/json'
        )
        return response

    # check Server is Running...
    @app.route('/ping')
    def ping():
        global LAST_PING_AT_TIME
        # print("GET: /ping")
        LAST_PING_AT_TIME = datetime.datetime.now().timestamp()
        return myRes({"dataStatus": "success", 'data': 'Server is Running...'})

    # html-path
    @app.route('/')
    def index_path():
        print("GET: /index")
        return app.send_static_file('index.html')

    # http://127.0.0.1:5000/stop
    @app.route('/stop', methods=['GET'])
    def stop():
        print("GET: /stop")
        # print("Shutdown: with Hard-STOP API(/stop")
        # Stop Server-Sevice.
        shutdown()
        return myRes({"dataStatus": "success", 'data': 'stoped'})

    # /api/1a
    @app.route('/api/<command>', methods=['GET'])
    def get_api(command):
        print("GET: /api/"+command)

        # motor-1
        if command == "ru":

            HatMdd10.m1AB()
            message = 'm1AB'

        elif command == "rd":

            HatMdd10.m1BA()
            message = 'm1BA'

        elif command == "r0":

            HatMdd10.m1Is0()
            message = 'm1Is0'

        # motor-2
        elif command == "lu":

            HatMdd10.m2AB()
            message = 'm2AB'
        elif command == "ld":

            HatMdd10.m2BA()
            message = 'm2BA'
        elif command == "l0":

            HatMdd10.m2Is0()
            message = 'm2Is0'

        elif command == "00":
            # # Stop All L,R

            HatMdd10.stopAll()
            message = 'stopAll'

        else:
            return myRes({"dataStatus": "error", 'message': 'not command: ' + command}, 404)

        return myRes({"dataStatus": "success", "message": message})

    return app


# def autoStopMotor(arg,HatMdd10):
def autoStopMotor(HatMdd10):
    global LAST_PING_AT_TIME
    global LIMIT_MOTOR_RUNNING
    t = threading.currentThread()
    while getattr(t, "do_run", True):
        if LAST_PING_AT_TIME != 0:
            diff_time = datetime.datetime.now().timestamp() - LAST_PING_AT_TIME
            if diff_time > LIMIT_MOTOR_RUNNING:
                # stop all motor
                HatMdd10.stopAll()
                LAST_PING_AT_TIME = 0
        time.sleep(1)
    print("Stopping Thread.")


def main():
    try:
        # init driveMotor
        HatMdd10 = BedMotor.HatMdd10()
        # start threading
        # t = threading.Thread(target=autoStopMotor, args=("task",HatMdd10,))
        t = threading.Thread(target=autoStopMotor, args=(HatMdd10,))
        t.start()
        # init flask
        app = create_app(HatMdd10)
        # app.run(host='0.0.0.0')
        app.run(host='0.0.0.0', port=5000, debug=False)
    except Exception as err:
        print(str(err.args))
    except KeyboardInterrupt:
        print("\n", "CTRL+C")
    else:
        print('some Err: server is Stoped.')
    finally:
        # Fixed: stop slower 1.9s
        HatMdd10.stopAll()
        # clear threading
        t.do_run = False
        t.join()
        # clear driveMotor
        HatMdd10.cleanup()


if __name__ == '__main__':
    main()

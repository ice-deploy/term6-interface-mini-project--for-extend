# NOTE

___
## (api <= v2.1)
- อยู่ใน https://github.com/ice-deploy/term6-interface-mini-project-python

<br>

___
## api v2.2.x
* with-http
```
Routes:
- /                     //html 
- /mobile               //html for mobile
        (mouse-down-mobile = 'https://stackoverflow.com/questions/11144370/using-mousedown-event-on-mobile-without-jquery-mobile')
- /ping                 //
- /api/{...}    [ru=1a,rd=1b,r0=10], [lu=2a,ld=2b,l0=20] 
                    //หมายเหตุ r0=right stop
                    //หมายเหตุ return ชื่อfunction จาก lib(class)ควบคุมมอเตอร์
```

* * ผู้ใช้(API)รู้แค่ ซ้าย/ขวา ขึ้น/ลง
* * การ mapping motor1 เป็น ซ้ายหรือขวา วิ่งจาก A->B หรือ B->A จะกำหนดที่ API(Server)
* * ตรวจสอบการเชื่อมต่อด้วยการ ping(ตรวจรวมไม่ได้ตรวจแยกแต่ละตัวแล้ว) //ping ไม่ควรเกิน 900ms (loop 1.9s = loopทุกๆ-1s, pingน้อยกว่า-900ms )
* * ฝั่ง Client ควร Check ด้วยว่าเวลา Call อะไรมามี returnถูกไหม (ขึ้น SnakeBar networkไม่เสถียร)

<!-- *** -->
<br>

___
## api-v3.x.x
- with-websocket

***
<br>
<br>
<br>

# libs ที่ใช้
- (JS) vue, axios
- (python) flask, websockets, RPi.GPIO
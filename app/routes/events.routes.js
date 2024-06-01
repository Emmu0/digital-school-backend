const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Event = require("../models/events.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
    const { body, validationResult } = require("express-validator");
    var router = require("express").Router();
  
    // ................................ Create a new event ................................
    router.post( "/", fetchUser,[],
      async (req, res) => {
        
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({ errors: errors.array() });
        }
        console.log("event route req.body => ", req.body);
        Event.init(req.userinfo.tenantcode);
        const eventRecord = await Event.CreateEvent(req.body);
        if (!eventRecord) {
          return res.status(400).json({ errors: "Bad Request" });
        }
        return res.status(201).json(eventRecord);
      }
    );

    //   ----------------------- Update Event -------------------

router.put("/:id", fetchUser,
    [
        body("event_type").notEmpty().isString(),
        body("start_date").notEmpty().isString(), 
        body("start_time").notEmpty().isString(), 
        body("end_date").notEmpty().isString(),
        body("end_time").notEmpty().isString(), 
    ],
     async (req, res) => {
     

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
       return res.status(400).json({ errors: errors.array() });
    }

     const eventId = req.params.id; 
     console.log('eventId=====>', eventId);
     const eventData = req.body;
     console.log('eventData=====>', eventData);
     Event.init(req.userinfo.tenantcode);
     const updateEvent = await Event.updateEventById(eventId, eventData);
    
     if (!updateEvent) {
        return res.status(404).json({ error: "Exam title not found" });
      }
     return res.status(200).json(updateEvent);
     }
   );

   //   ----------------------- Get All Events -------------------
   router.get("/getallevents", fetchUser, async (req, res) => {
    //Check permissions
    
    
    Event.init(req.userinfo.tenantcode);
    const events = await Event.findAllEvents();
    console.log('events', events)
    if (events) {
      res.status(200).json(events);
    } else {
      res.status(200).json({ "success": false, "message":"Bad Request" });
    }
  });


  //   ----------------------- Delete Event -------------------
  router.delete("/:id", fetchUser, async (req, res) => {
    
    Event.init(req.userinfo.tenantcode);
    const result = await Event.deleteEvent(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });

  //   ----------------------- Get By Id events -------------------

  router.get("/:id", fetchUser, async (req, res) => {
     try {
     
    
    
     const eventId = req.params.id;
     Event.init(req.userinfo.tenantcode);
     const eventRecord = await Event.EventFindById(eventId);
    
    if (eventRecord) {
     return res.status(200).json(eventRecord);
     } else {
     return res.status(404).json({ success: false, message: "No record found" });
     }
     } catch (error) {
     console.log("System Error:", error);
     return res.status(400).json({ success: false, message: error });
   }
 });


  app.use(process.env.BASE_API_URL + "/api/events", router);
};

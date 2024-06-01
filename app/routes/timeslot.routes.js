/**
 * @author : Pooja Vaishnav
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Timeslot = require("../models/timeslot.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();

  //add record 
  router.post("/", fetchUser, [
    body('type', 'Please enter Type').isLength({ min: 1 }),
    body('start_time', 'Please enter Start time').isLength({ min: 1 }),
    body('end_time', 'Please enter End time').isLength({ min: 1 }),
    body('status', 'Please enter Status').isLength({ min: 1 }),
    body('session_id', 'Please enter Session').isLength({ min: 1 }),
  ],

    async (req, res) => {
     
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      console.log('req.bodyy=>',req.body)
      Timeslot.init(req.userinfo.tenantcode);
      let duplicate = await Timeslot.duplicateRecord(null, req.body);
      console.log('what us duplicate==>',duplicate)
      if (!duplicate) {
        const result = await Timeslot.addRecord(req.body, req.userinfo.id);
        if (result) {
          return res.status(200).json({ "success": true, "result": result });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      } else {
        console.log('first ElIOOO')
        return res.status(200).json({ "success": false, "message": "Record is already exist!" });
      }
    });

  //fetch all record
  router.get("/", fetchUser, async (req, res) => {
   
    Timeslot.init(req.userinfo.tenantcode);
    const result = await Timeslot.fetchAllRecords();
    if (result) {
      res.status(200).json(result);
    } else {  
      console.log('first',result)
      res.status(400).json({ errors: "No data" ,result});
    }

  });

  //fetch record by id
  router.get("/:id", fetchUser, async (req, res) => {
    try {
     
      Timeslot.init(req.userinfo.tenantcode);
      let result = await Timeslot.fetchRecordById(req.params.id);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });


  //update record
  router.put("/:id", fetchUser, async (req, res) => {
    try {
     
      const { type, start_time, end_time, status } = req.body;
      const errors = [];
      const timeSlotRec = {};

      if (req.body.hasOwnProperty("type")) { timeSlotRec.type = type };
      if (req.body.hasOwnProperty("start_time")) { timeSlotRec.start_time = start_time };
      if (req.body.hasOwnProperty("end_time")) { timeSlotRec.end_time = end_time };
      if (req.body.hasOwnProperty("status")) { timeSlotRec.status = status };

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      Timeslot.init(req.userinfo.tenantcode);
      let resultCon = await Timeslot.fetchRecordById(req.params.id);
      if (resultCon) {
        let duplicate = await Timeslot.duplicateRecord(req.params.id, req.body);

        if (!duplicate) {
          console.log('firstduplicate===>',duplicate)
          console.log('firstduplicate===>',timeSlotRec)
        resultCon = await Timeslot.updateRecordById(req.params.id, timeSlotRec, req.userinfo.id);
        if (resultCon) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        }else{
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      }else{
        console.log('first elssss')
        return res.status(200).json({ "success": false, "message": "Record is already exist!" });
      }
        
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }

    } catch (error) {
      res.status(400).json({ errors: error });
    }

  });

  //delete record by id
  router.delete("/:id", fetchUser, async (req, res) => {
   
    Timeslot.init(req.userinfo.tenantcode);
    console.log('req.params.id = ', req.params.id);
    const result = await Timeslot.deleteRecord(req.params.id);
    console.log('result of delete subject = ', result); 
    if (result)
      return res.status(200).json(
        {
          "success": false,
          "message": "This Record has refrence in another table."
        });

    res.status(200).json(
      {
        "success": true,
        "message": "Successfully Deleted"
      });
  });

  app.use(process.env.BASE_API_URL + '/api/timeslots', router);
};
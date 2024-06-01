/**
 * @author : Pooja Vaishnav
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Timetable = require("../models/timetable.model.js");
const TimeSlotModel = require("../models/timeslot.model.js");

//const permissions = require("../constants/permissions.js");
const { truncate } = require("fs");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");
  var router = require("express").Router();

  //add record
  router.post("/", fetchUser, async (req, res) => {
    const errors = validationResult(req);

    // console.log('insie thebpost222',errors)
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    //   console.log('req.bodyySTTTTT88=>', req.body)
    Timetable.init(req.userinfo.tenantcode);
    console.log("databody", req.body);
    let result = await Timetable.upsertRecords(req.body);
    console.log("result", result);
    if (result) {
      return res.status(200).json(result);
    } else {
      return res.status(200).json({ success: false, message: "Bad Request" });
    }
  });

  //add record
  router.post("/onEditInsert", fetchUser, async (req, res) => {
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    Timetable.init(req.userinfo.tenantcode);
    for (const timeSlot in req.body) {
      console.log("timeSlot11==>", timeSlot);
      console.log("req.body[timeSlot]==>");
      let data = req.body[timeSlot];
      for (const entry of data) {
        console.log("entry@@ final", entry);
        if (entry.length > 0) {
          console.log("entry====>", entry[0]);
          console.log(
            "Object.keys(entry[0]).length=>",
            Object.keys(entry[0]).length
          );
          if (Object.keys(entry[0]).length === 8) {
            console.log("first");
            let firstObject = entry[0];
            console.log("firstObject@@=>", firstObject);
            // let resultCon = await Timetable.fetchRecordById(firstObject.id, firstObject.contact_id, firstObject.subject_id);
            // console.log('first resultCon', resultCon)
            // if (resultCon === null) {
            Timetable.init(req.userinfo.tenantcode);
            let duplicate = await Timetable.duplicateRecord(null, firstObject);
            console.log("duplicate@@@@=>", duplicate);
            if (duplicate === null) {
              console.log("firstduplicate===>", duplicate);
              console.log("update entry==>", entry);
              let resultCon = await Timetable.addRecordOnEdit(
                firstObject,
                req.userinfo.id
              );
              console.log("first resultCon==>", resultCon);
              if (resultCon) {
                console.log("inside the if@@@!=>", resultCon);
                return res.status(200).json({
                  success: true,
                  message: "Record created successfully",
                  resultCon,
                });
              }
            } else {
              console.log("ghdjgads");
              return res.status(200).json({ success: false });
            }
          }
        }
      }
    }
  });

  //get time table daywise
  router.get(
    "/daywise/classid/:classId/sectionid/:sectionId?",
    fetchUser,
    async (req, res) => {
      //console.log("req.userinfo.tenantcode", req.userinfo.tenantcode);

      Timetable.init(req.userinfo.tenantcode);

      TimeSlotModel.init(req.userinfo.tenantcode);

      const timeSlots = await TimeSlotModel.fetchAllRecords();

      const timeTables = await Timetable.fetchRecords(
        req.params.classId,
        req.params.sectionId
      );
      const days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ];

      let timeSlotsResult = [];
      let timeSlotObjs = [];
      let isEdit = false;
      for (const day of days) {
        let timeSlotsDay = [];
        let dayTimetable = { day: day };
        for (const timeSlot of timeSlots) {
          let key = `${timeSlot.id}|${day}`;
          //console.log(key);
          let timeTableRec = timeTables?.find(
            (record) =>
              record.time_slot_id === timeSlot.id && record.day === day
          );

          let timeTable = { time_slot: timeSlot };
          if (timeTableRec) {
            timeTable = {
              id: timeTableRec.id,
              teacher: timeTableRec.teacher_name,
              contact_id: timeTableRec.contact_id,
              subject: timeTableRec.subject_name,
              subject_id: timeTableRec.subject_id,
              section_id: timeTableRec.section_id,
              time_slot_id: timeTableRec.time_slot_id,
              class_id: timeTableRec.class_id,
              session_id: timeTableRec.session_id,
            };
            isEdit = true;
          } //
          let tsObj = { timetable: timeTable };
          timeSlotsDay.push(tsObj);
        }
        dayTimetable.data = timeSlotsDay;
        //console.log("timeSlotsDay", timeSlotsDay);
        timeSlotObjs.push(dayTimetable);
      }

      //console.log(timeSlotObjs);
      timeSlotsResult = timeSlotObjs; //.push(timeSlotObj);

      if (timeSlotsResult) {
        res
          .status(200)
          .json({ success: true, is_edit: isEdit, timeSlotsResult });
      } else {
        console.log("first", timeTableMap);
        res
          .status(200)
          .json({ success: false, errors: "No data", timeTableMap });
      }
    }
  );

  //fetch all record
  router.get("/:type", fetchUser, async (req, res) => {
    
    Timetable.init(req.userinfo.tenantcode);
    const result = await Timetable.fetchAllRecords(req.params.type);
    console.log("result@@@=>", result);
    if (result) {
      res.status(200).json({ success: true, result });
    } else {
      console.log("first", result);
      res.status(200).json({ success: false, errors: "No data", result });
    }
  });
  //fetch all record Teacher
  router.get("/teacher/:contactId/:sessionId", fetchUser, async (req, res) => {
   
    Timetable.init(req.userinfo.tenantcode);
    const result = await Timetable.fetchAllRecordsWithTeacher(
      req.params.contactId,
      req.params.sessionId
    );
    console.log("result@@@=>", result);
    if (result) {
      res.status(200).json({ success: true, result });
    } else {
      console.log("first43554", result);
      res.status(200).json({ success: false, errors: "No data", result });
    }
  });

  //fetch all record using class id
  router.get(
    "/teacher/:type/:contactid/:currentYearId",
    fetchUser,
    async (req, res) => {
      console.log("inside the gettt teaer=>", req.params);
      
      Timetable.init(req.userinfo.tenantcode);
      const result = await Timetable.fetchAllRecordsByTeacher(
        req.params.type,
        req.params.contactid,
        req.params.currentYearId
      );
      console.log("result@@@=>HHH", result);
      if (result) {
        console.log("Hye ingdg=>");
        return res.status(200).json(result);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    }
  );
  //fetch all record using class id
  router.get(
    "/class/:sectionid/:currentYearId/:type/",
    fetchUser,
    async (req, res) => {
      console.log("inside the gettt classoFff=>", req.params);
      
      Timetable.init(req.userinfo.tenantcode);
      const result = await Timetable.fetchAllRecordsByClassId(
        req.params.sectionid,
        req.params.currentYearId,
        req.params.type
      );
      console.log("result@@@=>HHH", result);
      const dayOfLoop = [];
      for (const res of result) {
        const key = `${res.day.toLowerCase()}-slot-${1}`;
        const value = {
          timeslotid: res.time_slot_id,
          contact_id: res.contact_id,
          subject_id: res.subject_id,
        };
        dayOfLoop.push({ [key]: value });
      }
      console.log("dayOfLoop#@@$@+>", dayOfLoop);

      const TimeSlot = []; // Assuming TimeSlot is defined elsewhere
      const slot1 = [];
      const slot2 = [];

      for (const slots of timeSlots) {
        for (const day of dayOfLoop) {
          console.log("DAya**(&(=>", day);
          if (Object.keys(day)[0].includes("slot-1")) {
            slot1.push(day);
          }
          if (Object.keys(day)[0].includes("slot-2")) {
            slot2.push(day);
          }

          const slots = {
            time: slot1,
            recordid: slot1.time_slot_id,
            time: slot2,
            recordid: slot1.time_slot_id,
            time: slot3,
            recordid: slot1.time_slot_id,
            time: slot4,
            recordid: slot1.time_slot_id,
          };
          TimeSlot.push(slots);
        }
      }
      console.log("TimeSlot@!@@!=>", TimeSlot);
      if (result) {
        return res.status(200).json(result);
      } else {
        console.log("ghhdsghguyyyyy");
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    }
  );
  router.get("timeslot/:timeslot", fetchUser, async (req, res) => {
   
    const result = await Timetable.fetchAllRecordsByIds(req.params.timeslot);
    console.log("result@@@=>HHH", result);
    if (result) {
      return res.status(200).json(result);
    } else {
      return res
        .status(200)
        .json({ success: false, message: "No record found" });
    }
  });
  //fetch record by id
  router.get("/:id", fetchUser, async (req, res) => {
    try {
      console.log("type meyhd");      
      Timetable.init(req.userinfo.tenantcode);
      let result = await Timetable.fetchRecordById(req.params.id);
      console.log("result@!~=>", result);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ success: false, message: error });
    }
  });

  //fetch record by contact_id
  router.get("/teacher/:contactId", fetchUser, async (req, res) => {
    console.log("TeacherWise32");
    const contactId = req.params.contactId;
    try {
      Timetable.init(req.userinfo.tenantcode);
      let result = await Timetable.fetchRecordByTeacherWise(contactId);
      console.log("result@!~=>", result);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No56587pooja record found" });
      }
    } catch (error) {
      return res.status(400).json({ success: false, message: error });
    }
  });
  //update record
  router.put("/update", fetchUser, async (req, res) => {
    try {
      console.log("what is upfayeec=>", req.body);
      Timetable.init(req.userinfo.tenantcode);
      // console.log('req.body@@',req.body)
      for (const timeSlot in req.body) {
        console.log("timeSlot11==>", timeSlot);
        console.log("req.body[timeSlot]==>");
        let data = req.body[timeSlot];
        for (const entry of data) {
          console.log("entry@@ final", entry);
          if (entry.length > 0) {
            console.log("entry====>", entry[0]);
            console.log("entry12222==>", entry);
            console.log("first entry=>", entry[0].contact_id);
            console.log(
              "entry.id,entry.contact_id,entry.subject_idW=>",
              entry.id,
              entry.contact_id,
              entry.subject_id
            );
            let firstObject = entry[0];
            console.log("firstObject@@=>", firstObject);
            let resultCon = await Timetable.fetchRecordById(
              firstObject.id,
              firstObject.contact_id,
              firstObject.section_id_id,
              firstObject.subject_id
            );
            console.log("resultConresultConresultCon", resultCon);
            if (resultCon != null) {
              let duplicate = await Timetable.duplicateRecord(
                resultCon.id,
                resultCon
              );
              console.log("duplicate@@@@=>", duplicate);
              console.log(
                "Object.keys(data).length > 0=>",
                Object.keys(duplicate).length > 0
              );
              if (Object.keys(duplicate).length > 0) {
                console.log("firstduplicate===>", duplicate);
                console.log("update entry==>", entry);
                console.log("fivhv=>", entry.contactId);
                if (entry.classid) {
                  delete entry.classid;
                }
                delete entry[0].section_name;
                delete entry[0].contact_name;
                delete entry[0].subject_name;
                delete entry[0].classname;
                delete entry[0].class_id;
                console.log("entry[0]kk=>", entry[0]);
                let resultCon = await Timetable.updateRecordById(
                  entry[0].id,
                  entry[0],
                  req.userinfo.id
                );
                console.log("first resultCon==>", resultCon);
                if (resultCon) {
                  console.log("inside the if@@@!=>", resultCon);
                  //return res.status(200).json({ "success": true, "message": "Record updated successfully", "result": resultCon });
                } else {
                  //  return res.status(200).json({ "success": false, "message": "Bad Request" });
                }
              } else {
                // console.log('first elssss')
                //return res.status(200).json({ "success": false, "message": "Record is already exist!" });
              }
              //console.log('first if11111',resultCon)
            }
          }
        }
      }
      return res
        .status(200)
        .json({ success: true, message: "Record updated successfully" });
    } catch (error) {
      console.log("errror=>", error);
      res.status(400).json({ errors: error });
    }
  });

  //delete record by id
  router.delete("/:id", fetchUser, async (req, res) => {
    
    Timetable.init(req.userinfo.tenantcode);
    const result = await Timetable.deleteRecord(req.params.id);
    console.log("result of delete subject = ", result);
    if (result === "Success")
      return res.status(200).json({
        success: true,
        message: "Successfully Deleted",
      });
    return null;
  });

  router.get("/classid/:classId/sectionid/:sectionId?", fetchUser,async (req, res) => {

      Timetable.init(req.userinfo.tenantcode);

      TimeSlotModel.init(req.userinfo.tenantcode);

      const timeSlots = await TimeSlotModel.fetchAllRecords();

      const timeTables = await Timetable.fetchRecords(
        req.params.classId,
        req.params.sectionId
      );
      const days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ];
      // Creating a map of objects
      const timeTableMap = new Map();
      /* if (timeTables && timeTables.length > 0) {
        for (const timeTable of timeTables) {
          timeTableMap.set(
            timeTable.time_slot_id + "|" + timeTable.day,
            timeTable
          );
        }
      } */

      let timeSlotsResult = [];
      let timeSlotObjs = [];
      let isEdit = false;
      for (const timeSlot of timeSlots) {
        let dayIndex = 0;
        let timeSlotsDay = [];
        let timeSlotObject = { time_slot: timeSlot };

        for (const day of days) {
          let key = `${timeSlot.id}|${day}`;
          //console.log(key);
          let timeTableRec = timeTables?.find(
            (record) =>
              record.time_slot_id === timeSlot.id && record.day === day
          );
          //console.log("timeTableRec@@@", timeTableRec);
          let timeTable = {};
          if (timeTableRec) {
            timeTable = {
              id: timeTableRec.id,
              teacher: timeTableRec.teacher_name,
              contact_id: timeTableRec.contact_id,
              subject: timeTableRec.subject_name,
              subject_id: timeTableRec.subject_id,
              section_id: timeTableRec.section_id,
              time_slot_id: timeTableRec.time_slot_id,
              class_id: timeTableRec.class_id,
              session_id: timeTableRec.session_id,
              day: timeTableRec.day,
            };
            isEdit = true;
          } else {
            timeTable = null;
          } //
          let tsObj = { day: day, timetable: timeTable };
          timeSlotsDay.push(tsObj);
        }
        timeSlotObject.data = timeSlotsDay;
        //console.log("timeSlotsDay", timeSlotsDay);
        timeSlotObjs.push(timeSlotObject);
      }

      //console.log(timeSlotObjs);
      timeSlotsResult = timeSlotObjs; //.push(timeSlotObj);

      if (timeSlotsResult) {
        res
          .status(200)
          .json({ success: true, is_edit: isEdit, timeSlotsResult });
      } else {
        console.log("first", timeTableMap);
        res
          .status(200)
          .json({ success: false, errors: "No data", timeTableMap });
      }
    }
  );
  app.use(process.env.BASE_API_URL + "/api/timetable", router);
};
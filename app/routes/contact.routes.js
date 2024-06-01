/**
 * Handles all incoming request for /api/contacts endpoint
 * DB table for this public.contact
 * Model used here is contact.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/contacts
 *              GET     /api/contacts/:id
 *              POST    /api/contacts
 *              PUT     /api/contacts/:id
 *              DELETE  /api/contacts/:id
 * 
 * @author      Farhan Khan
 * @date        Feb, 2023
 * @copyright   www.ibirdsservices.com  
 */

const e = require("express");
const Timetable = require("../models/timetable.model.js");
const { fetchUser } = require("../middleware/fetchuser.js");
const Contact = require("../models/contact.model.js");
//const permissions = require("../constants/permissions.js");


module.exports = app => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  // ................................ Create a new Contact ................................
  router.post("/", fetchUser, [],

    async (req, res) => {
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Contact.init(req.userinfo.tenantcode);
      const contactRec = await Contact.create(req.body, req.userinfo.id);

      if (!contactRec) {
        return res.status(400).json({ errors: "Bad Request" });
      }

      return res.status(201).json(contactRec);
    }
  );
  ///duplicay
  router.post("/dupli/", fetchUser, [
  ],
    async (req, res) => {
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Contact.init(req.userinfo.tenantcode);
      let duplicate = await Contact.duplicateRecord(null, req.body);//check duplicate Record
      if (duplicate) {

        return res.status(200).json({ "success": false, "message": "Record already exists." });
      } else {

        return res.status(200).json({ "success": false, "message": null });
      }
      return null;
    }
  );

  router.get("/teacher", fetchUser, async (req, res) => {
    Contact.init(req.userinfo.tenantcode);
    Timetable.init(req.userinfo.tenantcode);
    const allTeachers = await Contact.getAllTeacherRecords(); //get Records
    const timeTables = await Timetable.fetchRecords(
      (classId = null),
      (sectionId = null)
    );
    const teachers = {};
    for (const teacher of allTeachers) {
      teachers[teacher.id] = {
        id: teacher.id,
        teachername: teacher.teachername,
        schedule: [],
      };
    }
    
    try {
      for (const item of timeTables) {
        teachers[item.contact_id].schedule.push({
          id: item.id,
          start_time: item.start_time,
          end_time: item.end_time,
          timeslot_id: item.timeslotid,
          class: item.classname,
          class_id: item.class_id,
          section: item.section_name,
          section_id: item.section_id,
          subject: item.subject,
          day: item.day,
        });
      }
    } catch (error) {
     console.log(error);
      // JSON.status(400).send({success:false,message:error})
    }
    

    // Convert object values to array
    const teacherData = Object.values(teachers);

    if (teacherData) {
      res.status(200).json(teacherData);
    } else {
      res.status(200).json({ success: false, message: "No record found!" });
    }
  });
  /* Created By Pooja Vaishnav */
  // ................................ Create a new Contact based on recordtypes................................
  router.post("/parentsData", fetchUser, [],
    async (req, res) => {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Contact.init(req.userinfo.tenantcode);
      let duplicate = await Contact.duplicateRecord(null, req.body);//check duplicate Record
      if (duplicate === null) {
        const contactRec = await Contact.createContact(req.body, req.userinfo.id);
        if (contactRec) {
          return res.status(200).json({ "success": true, "message": "Successfully Created Record" });
        } else {
          return res.status(400).json({ errors: "Bad Request" });
        }
      } else {

        return res.status(200).json({ "success": false, "message": "Parent Contact is already exist" });
      }
      // if (!contactRec) {
      //   return res.status(400).json({ errors: "Bad Request" });
      // }
      return res.status(201).json(contactRec);
    }
  );
  // .....................................Get All Students Contacts........................................
  router.get("/student", fetchUser, async (req, res) => {
   
    Contact.init(req.userinfo.tenantcode);
    const contacts = await Contact.findAllStudents();
    if (contacts) {
      res.status(200).json(contacts);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });
  // .....................................Get All Staff Contacts........................................
  router.get("/staff", fetchUser, async (req, res) => {
    Contact.init(req.userinfo.tenantcode);
    const contacts = await Contact.findAllStaffs();
    if (contacts) {
      res.status(200).json(contacts);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });

  /* added by Ronak Sharma  */
  // .....................................Get All Driver Contacts........................................
  router.get("/driver", fetchUser, async (req, res) => {
    //Check permissions

    Contact.init(req.userinfo.tenantcode);
    const drivers = await Contact.findAllDrivers();
    if (drivers) {
      res.status(200).json(drivers);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  // .....................................Get All Parents Contacts........................................
  router.get("/parent", fetchUser, async (req, res) => {

    Contact.init(req.userinfo.tenantcode);
    const contacts = await Contact.findAllParents();
    if (contacts) {
      res.status(200).json(contacts);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  // .....................................Get Contact by Id........................................
  router.get("/:id", fetchUser, async (req, res) => {
    try {
     
      Contact.init(req.userinfo.tenantcode);
      let contactRec = await Contact.findById(req.params.id);

      if (contactRec) {
        return res.status(200).json(contactRec);
      } else {
        return res.status(200).json({ success: false, message: "No record found" });
      }
    } catch (error) {

      return res.status(400).json({ success: false, message: error });
    }
  });

  //......................................Update Contact.................................
  router.put("/:id", fetchUser, async (req, res) => {
    try {

      const { salutation, firstname, lastname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, recordtype, religion, } = req.body; //removed 'department' by Pawan : 21-09-2023
      const errors = [];
      const contactRec = {};

      if (req.body.hasOwnProperty("salutation")) {
        contactRec.salutation = salutation;
      }
      if (req.body.hasOwnProperty("firstname")) {
        contactRec.firstname = firstname;
      }
      if (req.body.hasOwnProperty("lastname")) {
        contactRec.lastname = lastname;
      }
      if (req.body.hasOwnProperty("dateofbirth")) {
        contactRec.dateofbirth = dateofbirth;
      }
      if (req.body.hasOwnProperty("gender")) {
        contactRec.gender = gender;
      }
      if (req.body.hasOwnProperty("phone")) {
        contactRec.phone = phone;
      }
      if (req.body.hasOwnProperty("email")) {
        contactRec.email = email;
      }
      if (req.body.hasOwnProperty("adharnumber")) {
        contactRec.adharnumber = adharnumber;
      }
      if (req.body.hasOwnProperty("state")) {
        contactRec.state = state;
      }
      if (req.body.hasOwnProperty("profession")) {
        contactRec.pincode = profession;
      }
      if (req.body.hasOwnProperty("pincode")) {
        contactRec.pincode = pincode;
      }
      if (req.body.hasOwnProperty("street")) {
        contactRec.street = street;
      }
      if (req.body.hasOwnProperty("city")) {
        contactRec.city = city;
      }
      if (req.body.hasOwnProperty("country")) {
        contactRec.country = country;
      }
      if (req.body.hasOwnProperty("classid")) {
        contactRec.classid = classid;
      }
      if (req.body.hasOwnProperty("spousename")) {
        contactRec.spousename = spousename;
      }
      if (req.body.hasOwnProperty("qualification")) {
        contactRec.qualification = qualification;
      }
      if (req.body.hasOwnProperty("description")) {
        contactRec.description = description;
      }
      if (req.body.hasOwnProperty("parentid")) {
        contactRec.parentid = parentid;
      }
      // if (req.body.hasOwnProperty("department")) { //Commented by Pawan : 21-09-2023
      //   contactRec.department = department;
      // }
      if (req.body.hasOwnProperty("recordtype")) {
        contactRec.recordtype = recordtype;
      }
      if (req.body.hasOwnProperty("religion")) {
        contactRec.religion = religion;
      }
      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      console.log('Req.Body==>',req.body);
      Contact.init(req.userinfo.tenantcode);
      console.log('req.params.id==>',req.params.id);
      let resultCon = await Contact.findById(req.params.id);
      console.log('resultCon==>',resultCon);
      if (resultCon) {
        console.log('req.params.id->',req.params.id);
        console.log('contactRec->',contactRec);
        console.log('req.userinfo.id->',req.userinfo.id);
        resultCon = await Contact.updateById(req.params.id, contactRec, req.userinfo.id);
        console.log('UpdateResultCon==>',resultCon);
        if (resultCon) {
          return res.status(200).json({ success: true, message: "Record updated successfully" });
        }
        return res.status(200).json(resultCon);
      } else {
        return res.status(200).json({ success: false, message: "No record found" });
      }
    } catch (error) {
      res.status(400).json({ errors: error });
    }
  });

  // Delete a Tutorial with id
  router.delete("/:id", fetchUser, async (req, res) => {
    try {

      Contact.init(req.userinfo.tenantcode);
      const deleteResult = await Contact.deleteContact(req.params.id);

      if (deleteResult && deleteResult.message) {
        return res.status(200).json({ success: true, message: deleteResult.message });
      } else if (deleteResult && deleteResult.error) {
        return res.status(400).json({ success: false, message: deleteResult.error });
      } else {
        return res.status(404).json({ success: false, message: "Employee not found" });
      }
    } catch (error) {
      if (error.message === "Record has reference in another table. Deletion not allowed.") {
        return res.status(400).json({ success: false, message: "Record has reference in another table. Deletion not allowed." });
      } else {

        return res.status(500).json({ success: false, message: "Internal Server Error" });
      }
    }
  });



  app.use(process.env.BASE_API_URL + "/api/contacts", router);
};

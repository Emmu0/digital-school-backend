/**
 * Handles all incoming request for /api/Subjects endpoint
 * DB table for this public.Subject
 * Model used here is Subject.model.js
 * SUPPORTED API ENDPOINTS
 *             GET     /api/Leads
 *              GET     /api/Leads/:id
 *              POST    /api/Leads
 *              PUT     /api/Leads/:id
 *              DELETE  /api/Leads/:id
 * 
 * @author      Aamir Khan
 * @date        Autust, 2023
 * @copyright   www.ibirdsservices.com  
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const lead = require("../models/lead.model.js");

module.exports = app => {


  const { body, validationResult } = require('express-validator');

  var router = require("express").Router();

  // ................................ Create a new lead ................................
  router.post("/", fetchUser, [
    // body('name', 'Please enter Subject Name').isLength({ min: 1 }),
  ],

    async (req, res) => {
     
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      lead.init(req.userinfo.tenantcode);
      const leadRec = await lead.create(req.body, req.userinfo.id);

      if (!leadRec) {
        return res.status(400).json({ errors: "Bad Request" });
      }

      return res.status(201).json(leadRec);

    });
  //Check Duplicacy
  router.post("/dupli/", fetchUser, [
  ],

    async (req, res) => {

     
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
    
      lead.init(req.userinfo.tenantcode);
      let duplicate = await lead.duplicateRecord(null, req.body);//check duplicate Record
      if (duplicate) {
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      } else {
        return res.status(200).json({ "success": false, "message": null });
      }
      return null;
    }
  );

  // .....................................Get All lead........................................
  router.get("/", fetchUser, async (req, res) => {
  
    lead.init(req.userinfo.tenantcode);
    const leads = await lead.findAll();
    if (leads) {
      res.status(200).json(leads);
    } else {
      console.log('insid ethe 4000');
      res.status(400).json({ errors: "No data" });
    }

  });

  //......................................Get subject by leadId.................................
  router.get("/:id", fetchUser, async (req, res) => {
    try {
     
      lead.init(req.userinfo.tenantcode);
      let resultCon = await lead.findById(req.params.id);
      if (resultCon) {
        return res.status(200).json(resultCon);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });


  //......................................Update lead.................................
  router.put("/:id", fetchUser, async (req, res) => {
    try {
      console.log('inside the try method@@@@@', req.params.id);
     
      const { firstname, lastname, status, class_id, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description,
        father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation } = req.body;
      const errors = [];
      const leadRec = {};
      console.log('req.params.id=>', req.params.id)
      if (req.body.hasOwnProperty("firstname")) { leadRec.firstname = firstname };
      if (req.body.hasOwnProperty("lastname")) { leadRec.lastname = lastname };
      if (req.body.hasOwnProperty("religion")) { leadRec.religion = religion };
      if (req.body.hasOwnProperty("dateofbirth")) { leadRec.dateofbirth = dateofbirth };
      if (req.body.hasOwnProperty("gender")) { leadRec.gender = gender };
      if (req.body.hasOwnProperty("email")) { leadRec.email = email };
      if (req.body.hasOwnProperty("adharnumber")) { leadRec.adharnumber = adharnumber };
      if (req.body.hasOwnProperty("phone")) { leadRec.phone = phone };
      if (req.body.hasOwnProperty("pincode")) { leadRec.pincode = pincode };
      if (req.body.hasOwnProperty("street")) { leadRec.street = street };
      if (req.body.hasOwnProperty("city")) { leadRec.city = city };
      if (req.body.hasOwnProperty("state")) { leadRec.state = state };
      if (req.body.hasOwnProperty("country")) { leadRec.country = country };
      if (req.body.hasOwnProperty("description")) { leadRec.description = description };
      if (req.body.hasOwnProperty("father_name")) { leadRec.father_name = father_name };
      if (req.body.hasOwnProperty("mother_name")) { leadRec.mother_name = mother_name };
      if (req.body.hasOwnProperty("father_qualification")) { leadRec.father_qualification = father_qualification };
      if (req.body.hasOwnProperty("mother_qualification")) { leadRec.mother_qualification = mother_qualification };
      if (req.body.hasOwnProperty("father_occupation")) { leadRec.father_occupation = father_occupation };
      if (req.body.hasOwnProperty("mother_occupation")) { leadRec.mother_occupation = mother_occupation };
      if (req.body.hasOwnProperty("status")) { leadRec.status = status }; //Add By Aamir khan Status Field
      if (req.body.hasOwnProperty("class_id")) { leadRec.class_id = class_id }; //Add By Aamir khan Status Field
      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      lead.init(req.userinfo.tenantcode);
      let resultCon = await lead.findById(req.params.id);
      if (resultCon) {
        console.log('leadRec==>', leadRec)
        resultCon = await lead.updateById(req.params.id, leadRec, req.userinfo.id, req.userinfo.tenantcode);
        console.log('first resultCOn#####=>', resultCon)
        if (resultCon) {
          console.log('inside the if$$$$$$', resultCon)
          return res.status(200).json({ "success": true, "message": "Record updated successfully", "lead": { resultCon } });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }


    } catch (error) {
      res.status(400).json({ errors: error });
    }

  });

  // Delete a Tutorial with id
  router.delete("/:id", fetchUser, async (req, res) => {
  
    lead.init(req.userinfo.tenantcode);
    const result = await lead.deleteLead(req.params.id);
    //========================= Add by Aamir khan code Start ======================
    if (result) {
      res.status(200).json({ "success": true, "message": "Successfully Deleted" });
    }
    else {
      res.status(400).json({ "success": true, "message": "Something went wrong!!" });
    }
    //========================= Aamir khan End ======================
  });

  app.use(process.env.BASE_API_URL + '/api/leads', router);
};

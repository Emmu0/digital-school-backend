/**
 * @author: Abdul Pathan
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const sectionModel = require("../models/section.model.js");
const permissions = require("../constants/permissions.js");


module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();


  //fetch All Records
  router.get("/:id?", fetchUser, async (req, res) => {    //Check permissions

    sectionModel.init(req.userinfo.tenantcode);
    const result = await sectionModel.getAllRecords(); //get Records
    if (result) {
      res.status(200).json(result);
    } else {
      return res.status(200).json({ "success": false, "message": "No record found" });
      // res.status(400).json({ errors: "No Record Found!" });
    }
  });
  //shahir bug fixed in the code
  router.get("/:id", fetchUser, async (req, res) => {    //Check permissions
    console.log('class req.params.id======>',req.params.id);
    try {

      sectionModel.init(req.userinfo.tenantcode);
      let result = await sectionModel.getRecordById(req.params.id);//get Record By Id
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  //fetch All Active Records with section name
  router.get("/class", fetchUser, async (req, res) => {

    //console.log('req.query.className@@+>',req.query.status)
    sectionModel.init(req.userinfo.tenantcode);
    const result = await sectionModel.getActiveSectionWithClass(); //fetch Records
    // console.log('result regfgfdh=>',result)
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ errors: "No Record found!" });
    }
  });
  //fetch RecordById
  router.get("/:id", fetchUser, async (req, res) => {    //Check permissions
    try {


      sectionModel.init(req.userinfo.tenantcode);
      let result = await sectionModel.getRecordById(req.params.id);//get Record By Id
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  //fetch RecordById
  router.get("/class/:id", fetchUser, async (req, res) => {    //Check permissions
    try {


      sectionModel.init(req.userinfo.tenantcode);
      let result = await sectionModel.getClassSections(req.params.id);//get Record By Id

      if (result) {
        return res.status(200).json({ "success": true, "record": result });
        // return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  //add Record
  router.post("/add", fetchUser, [
    body('class_id', 'Please enter class Name').isLength({ min: 1 }),
    body('name', 'Please enter Name').isLength({ min: 1 }),
    body('strength', 'Please enter Strength').isLength({ min: 1 }),
  ],

    async (req, res) => {   

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      sectionModel.init(req.userinfo.tenantcode);
      let duplicate = await sectionModel.duplicateRecord(null, req.body);
      if (!duplicate) {
        const result = await sectionModel.addRecord(req.body, req.userinfo.id);
        if (result) {
          return res.status(200).json({ "success": true, "result": result });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "Record is already exist" });
      }
    });

  //update Record
  router.put("/:id", fetchUser, async (req, res) => {
    try {


      const { class_id, name, strength, contact_id } = req.body;
      const errors = [];
      const sectionRecord = {};

      if (req.body.hasOwnProperty("class_id")) { sectionRecord.class_id = class_id };
      if (req.body.hasOwnProperty("name")) { sectionRecord.name = name };
      if (req.body.hasOwnProperty("strength")) { sectionRecord.strength = strength };

      //Changes by Shakib
      sectionRecord.contact_id = contact_id
      sectionRecord.contact_id = sectionRecord.contact_id === '' ? null : sectionRecord.contact_id;

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }


      sectionModel.init(req.userinfo.tenantcode);
      let result = await sectionModel.getRecordById(req.params.id);

      if (result) {

        let duplicate = await sectionModel.duplicateRecord(req.params.id, sectionRecord);//duplicate Record check
        if (!duplicate) {
console.log('duplicate pata kro 1');

          let responce = await sectionModel.updateRecordById(req.params.id, sectionRecord, req.userinfo.id);
console.log(responce,'duplicate pata kro');

          if (responce) {
            return res.status(200).json({ "success": true, "message": "Record updated successfully" });
          } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
          }
        } else {

          return res.status(200).json({ "success": false, "message": "Record is already exist" });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(200).json({ "success": false, "message": "Bad Request" });
    }
  });


  // update active/inactive record
  router.put("/active/:id", fetchUser, async (req, res) => {//Check permissions
    try {


      const { isactive } = req.body;
      const errors = [];
      const sectionRecord = {};

      if (req.body.hasOwnProperty("isactive")) { sectionRecord.isactive = isactive };

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }

      sectionModel.init(req.userinfo.tenantcode);

      let result = await sectionModel.getRecordById(req.params.id);


      if (result) {
        let responce = await sectionModel.updateSectionActiveInactiveRecord(req.params.id, sectionRecord, req.userinfo.id);
        if (responce) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        }
        return res.status(200).json(responce);

      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {

      res.status(400).json({ errors: error });
    }
  });

  app.use(process.env.BASE_API_URL + '/api/section', router);
}
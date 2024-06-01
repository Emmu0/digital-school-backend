/**
 * @author : Pooja Vaishnav
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const student_fee_installments = require("../models/student_fee_installments.model.js")
//const permissions = require("../constants/permissions.js");

module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();

  //add record 
  router.post("/", fetchUser, [],
  async (req, res) => {
   
  
    const records = req.body;
    if(records && Array.isArray(records) && records.length > 0) { 

      console.log('Creating new student installments:', records);

      let results = [];
      for(let i = 0; i < records.length; i++){
        console.log(`Processing record ${i + 1}`, records[i]);
        student_fee_installments.init(req.userinfo.tenantcode);
        const result = await student_fee_installments.addRecord(records[i], req.userinfo.id);
        console.log('Result:', result);

        results.push(result);
      }

      return res.status(200).json({ "success": true, "result": results });
    } else {
      return res.status(400).json({ "success": false, "message": "Bad Request" });
    }
  }
);

  // //fetch all record
  // router.get("/", fetchUser, async (req, res) => {
  
  //   student_fee_installments.init(req.userinfo.tenantcode);
  //   const result = await student_fee_installments.fetchAllRecords();
  //   if (result) {
  //     res.status(200).json(result);
  //   } else {  
  //     res.status(400).json({ errors: "No data" ,result});
  //   }

  // });

  //fetch record by id
  router.get("/:id?", fetchUser, async (req, res) => {
    try {
      

      student_fee_installments.init(req.userinfo.tenantcode);
      let result = await student_fee_installments.fetchRecordById(req?.params?.id);

      if (result) {
        return res.status(200).json({"success": true, "result": result});
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  router.get("/installments/:admissionid/:sessionid", fetchUser, async (req, res) => {
    try {
      const admissionid = req?.params?.admissionid;
      const sessionid = req?.params?.sessionid;

      student_fee_installments.init(req.userinfo.tenantcode);
      let result = await student_fee_installments.fetchstudentInstallments(admissionid, sessionid);
      console.log('fetchstudentInstallments result-->', result);

      if (result) {
        return res.status(200).json({"success": true, "result": result[0].result});
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
    
      const errors = [];
      const timeSlotRec = {};

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      student_fee_installments.init(req.userinfo.tenantcode);
      let resultCon = await student_fee_installments.fetchRecordById(req.params.id);
      if (resultCon) {
       // let duplicate = await student_fee_installments.duplicateRecord(req.params.id, req.body);

        // if (!duplicate) {
        resultCon = await student_fee_installments.updateRecordById(req.params.id, req.body, req.userinfo.id);
        if (resultCon) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        }else{
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      // }else{
      //   return res.status(200).json({ "success": false, "message": "Record is already exist!" });
      // }
        
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }

    } catch (error) {
      res.status(400).json({ errors: error });
    }

  });

  //delete record by id
  router.delete("/:id", fetchUser, async (req, res) => {
    
   
      student_fee_installments.init(req.userinfo.tenantcode);
    const result = await student_fee_installments.deleteRecord(req.params.id);

    if(result.message){
      res.status(200).json({"success": true,"message": result.message});
    }
    else{
      return res.status(200).json({"success": false,"message": "Error while deleteing student fee installment."});
      }

  });

  app.use(process.env.BASE_API_URL + '/api/studentfeeinstallments', router);
};

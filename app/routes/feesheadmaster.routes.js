/**
 * @author: Pooja Vaishnav
 */

// const express = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const feesheadmaster = require("../models/feesheadmaster.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();


  //fetch All Records
  router.get("/", fetchUser, async (req, res) => { 
    
    feesheadmaster.init(req.userinfo.tenantcode);
    const result = await feesheadmaster.getAllRecords(req.query.name); 
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ errors: "No Record found!" });
    }
  });

   router.get("/status/:status", fetchUser, [
    ],

    async (req, res) => { 
    
    console.log('req.body',req.body)
    feesheadmaster.init(req.userinfo.tenantcode);
    const result = await feesheadmaster.getAllRecordsByStatus(req.params.status); //fetch Records
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ errors: "No Record found!" });
    }
  });
 

  //add Record
  router.post("/", fetchUser, [
   // body('classname', 'Please enter class Name').isLength({ min: 1 }),
  ],

    async (req, res) => {    //Check permissions
      
      const errors = validationResult(req);

      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      feesheadmaster.init(req.userinfo.tenantcode);
      let duplicate = await feesheadmaster.duplicateRecord(null, req.body);//check duplicate Record
      if (!duplicate) {
        const result = await feesheadmaster.addRecord(req.body, req.userinfo.id);
        console.log('result',result);
        if(result){
          return res.status(200).json({ success: true, message: "Record saved successfully!!"});
        }
        else{
          return res.status(401).json({ success: false, message: "Bad Request!!"});
        }
       
      }else{
        return res.status(400).json({ success: false, message: "Record is already exist" });
      }
    });

  //update Record
  router.put("/:id", fetchUser, async (req, res) => {//Check permissions
    try {
      console.log('inside update');
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      console.log('inside update record feeHead master record');
      console.log('request.params.id', req.params.id)
      console.log('request body', req.body);
      feesheadmaster.init(req.userinfo.tenantcode);
      let result = await feesheadmaster.getRecordById(req.params.id);
      console.log('result while edit',result);

      if (result) {
        let responce = await feesheadmaster.updateRecordById(req.params.id, req.body, req.userinfo.id);
        if (responce) {
          return res.status(200).json({ "success": true, "record": responce });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
    }
  }
  catch (error) {
      return res.status(200).json({ "success": false, "message": "Bad Request" });
    }
  });

  //delete Record
  router.delete("/:id", fetchUser, async (req, res) => {  //Check permissions
    

    console.log('inside delete method',req.params.id);
    feesheadmaster.init(req.userinfo.tenantcode);
    const result = await feesheadmaster.deleteRecord(req.params.id);//delete Record
    if (result) {
      res.status(200).json({ "success": true, "message": "Record Delete Successfully" });
    } else {
      return res.status(200).json({ "success": false, "message": "No Record found" });
    }
  });

  app.use('/api/feesheadmaster', router);
};

const express = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
//const permissions = require("../constants/permissions.js");
const discountLineItem = require("../models/discount_line_items.model.js");
const { body, validationResult } = require("express-validator");

module.exports = (app) => {
  var router = express.Router();

  // Create Discount Line Item
  router.post("/", fetchUser, [], async (req, res) => {
    try {
        
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const request = req.body;
        let results = [];
        console.log('request on backend-->', request);
        
        if (request?.discounts) {
            for (let i = 0; i < request.discounts.length; i++) {
                console.log('request.discounts[i].value-->', request.discounts[i].value);
                console.log('request.student_addmission_id-->', request.student_addmission_id);
                discountLineItem.init(req.userinfo.tenantcode);
                const existingRecord = await discountLineItem.checkForDuplicacy(request.student_addmission_id, request.discounts[i].value);
                if (existingRecord) {
                    throw new Error("Discount already applied on student");
                }
                console.log("inside routes-->", req.body);
                const newLineItem = {student_addmission_id : request.student_addmission_id, discountid: request.discounts[i].value};
                
                console.log("req.userinfo.tenantcode-->", req.userinfo.tenantcode);
                const result = await discountLineItem.create(newLineItem);
                results.push(result);
            }
        } else {
            throw new Error("Invalid discount data format");
        }

        return res.status(201).json(results);

    } catch (error) {
        console.error("Error:", error);
        return res.status(500).json({ error: error.message });
    }
});


  router.get("/", fetchUser, async (req, res) => {
    // Check permissions
    
    discountLineItem.init(req.userinfo.tenantcode);
    const result = await discountLineItem.fetchAllRecords();
    if (result) {
        res.status(200).json(result);
    } else {
        res.status(400).json({ errors: "No data" });
    }
});


  // Read Discount Line Item
  router.get("/:studentadid", fetchUser, async (req, res) => {
    try {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const lineItemId = req.params.studentadid;
      discountLineItem.init(req.userinfo.tenantcode);
      const result = await discountLineItem.findById(lineItemId);
      if (result) {
        return res.status(200).json({success: true, result: result});
      } else {
        return res.status(404).json({success: false, message: "Discount line item not found" });
      }
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  });

  // Update Discount Line Item
  router.put("/", fetchUser, async (req, res) => {
    try {


      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array()});
      }

      const newRecord = req.body;
      let removedRecord = [];
      let newRecords = [];
      let results = [];
      discountLineItem.init(req.userinfo.tenantcode);
      const existingRecord = await discountLineItem.findById(newRecord?.student_addmission_id);

      existingRecord.forEach((ext) => {
        if (!newRecord || !newRecord.discounts || !newRecord.discounts.some((itm) => itm.label === ext.discount_name)) {
            removedRecord.push(ext.id);
        }
    });

    if (newRecord && newRecord.discounts) {
        newRecords = newRecord.discounts.filter((newItem) =>
            !existingRecord.some((existingItem) => existingItem.discount_name === newItem.label)
        );
    }
      
    console.log('newRecords-->',newRecords);
    console.log('removedRecord-->',removedRecord);
    for(let i=0;i<newRecords.length;i++){
        const datatobeCreated = {student_addmission_id: newRecord.student_addmission_id, discountid: newRecords[i]?.value};
        discountLineItem.init(req.userinfo.tenantcode);
        const resultcreated = await discountLineItem.create(datatobeCreated);
        results.push(resultcreated);
    }
     
      if(removedRecord){
        for(let i=0;i<removedRecord.length;i++){
            discountLineItem.init(req.userinfo.tenantcode);
            const deletedResult = await discountLineItem.remove(removedRecord[i]);
            if(deletedResult){
            console.log('record deleted successfully!!');
            }
        }
       
      }
      return res.status(200).json({success: true});
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  });

  // Delete Discount Line Item
  router.delete("/:id", fetchUser, async (req, res) => {
    try {
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      const lineItemId = req.params.id;
      discountLineItem.init(req.userinfo.tenantcode);
      const result = await discountLineItem.remove(lineItemId);
      return res
        .status(200)
        .json({ message: "Discount line item deleted successfully" });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  });

  app.use("/api/discount-line-items", router);
};

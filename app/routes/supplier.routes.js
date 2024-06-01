const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Supplier = require("../models/supplier.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {
   
    Supplier.init(req.userinfo.tenantcode);
    const suppliers = await Supplier.findAll();
    if (suppliers) {
      res.status(200).json(suppliers);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


//   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {
     
      const supplierId = req.params.id;
      Supplier.init(req.userinfo.tenantcode);
      const supplier = await Supplier.findBySupplierId(supplierId);
      if (supplier) {
        res.status(200).json(supplier);
      } else {
        res.status(404).json({ errors: "Supplier not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });
  

  //   ---------------------Create New Supplier---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {
     
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Supplier.init(req.userinfo.tenantcode);

      const supplierRecord = await Supplier.createSupplier(req.body, req.userinfo.id);

      if (!supplierRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(supplierRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

    //   ---------------------Update Supplier by Id---------------------------

    router.put("/:id", fetchUser, [], async (req, res) => {
          
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
    
      const supplierId = req.params.id;
      const supplierData = req.body;
      Supplier.init(req.userinfo.tenantcode);
      const updateSupplier = await Supplier.updateById(
          supplierId,
          supplierData,
          req.userinfo.id
      );
      
      if (updateSupplier) {
                return res.status(200).json({ success: true, message: "Record updated successfully" });
              }
              return res.status(200).json(updateSupplier);
    });
   


 //   ----------------------- Delete Supplier -------------------

 router.delete("/:id", fetchUser, async (req, res) => {

    Supplier.init(req.userinfo.tenantcode);
    const result = await Supplier.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });
  
    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });
  

  app.use(process.env.BASE_API_URL + "/api/suppliers", router);
};

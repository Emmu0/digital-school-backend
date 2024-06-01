const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Purchase = require("../models/purchase.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {
    Purchase.init(req.userinfo.tenantcode);
    const purchases = await Purchase.findAll();
    if (purchases) {
      res.status(200).json(purchases);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  //   ---------------------Get By Id Book Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {


      const bookId = req.params.id;
      Purchase.init(req.userinfo.tenantcode);
      const purchase = await Purchase.findByPurchaseByBookId(bookId);
      if (purchase) {
        res.status(200).json(purchase);
      } else {
        res.status(404).json({ errors: "Purchase not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Get By Id Supplier Id---------------------------
  router.get("/supplierId/:id", fetchUser, async (req, res) => {
    try {


      const supplierId = req.params.id;
      Purchase.init(req.userinfo.tenantcode);
      const purchase = await Purchase.findByPurchaseBysupplierId(supplierId);
      if (purchase) {
        res.status(200).json(purchase);
      } else {
        res.status(404).json({ errors: "Purchase not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });

  //   ---------------------Create New Purchase---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Purchase.init(req.userinfo.tenantcode);

      const purchaseRecord = await Purchase.createPurchase(
        req.body,
        req.userinfo.id
      );

      if (!purchaseRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(purchaseRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  //   ---------------------Update Purchase by Id---------------------------

  router.put("/:id", fetchUser, [], async (req, res) => {



    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const purchaseId = req.params.id;
    const purchaseData = req.body;
    Purchase.init(req.userinfo.tenantcode);
    const updatePurchase = await Purchase.updateById(
      purchaseId,
      purchaseData,
      req.userinfo.id
    );

    if (updatePurchase) {
      return res.status(200).json({ success: true, message: "Record updated successfully" });
    }
    return res.status(200).json(updatePurchase);
  });


  //   ----------------------- Delete Purchase -------------------

  router.delete("/:id", fetchUser, async (req, res) => {


    Purchase.init(req.userinfo.tenantcode);
    const result = await Purchase.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });

  app.use(process.env.BASE_API_URL + "/api/purchases", router);
};

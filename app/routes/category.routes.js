const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Category = require("../models/category.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {

    Category.init(req.userinfo.tenantcode);
    const category = await Category.findAll();
    if (category) {
      res.status(200).json(category);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  //   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {
      const categoryId = req.params.id;
      Category.init(req.userinfo.tenantcode);
      const category = await Category.findByCategoryId(categoryId);
      if (category) {
        res.status(200).json(category);
      } else {
        res.status(404).json({ errors: "Category not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Create New Category---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Category.init(req.userinfo.tenantcode);

      const categoryRecord = await Category.createCategory(req.body, req.userinfo.id);

      if (!categoryRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(categoryRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });



  //   ---------------------Update Category by Id---------------------------

  router.put("/:id", fetchUser, [], async (req, res) => {



    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const categoryId = req.params.id;
    const categoryData = req.body;
    Category.init(req.userinfo.tenantcode);
    const updateCategory = await Category.updateById(
      categoryId,
      categoryData,
      req.userinfo.id
    );

    if (updateCategory) {
      return res.status(200).json({ success: true, message: "Record updated successfully" });
    }
    return res.status(200).json(updateCategory);
  });


  //   ----------------------- Delete Category -------------------

  router.delete("/:id", fetchUser, async (req, res) => {


    Category.init(req.userinfo.tenantcode);
    const result = await Category.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });


  app.use(process.env.BASE_API_URL + "/api/category", router);
};

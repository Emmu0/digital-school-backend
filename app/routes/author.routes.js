const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Author = require("../models/author.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {

    Author.init(req.userinfo.tenantcode);
    const authors = await Author.findAll();
    if (authors) {
      res.status(200).json(authors);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  //   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {



      const authorId = req.params.id;
      Author.init(req.userinfo.tenantcode);
      const author = await Author.findByAuthorId(authorId);
      if (author) {
        res.status(200).json(author);
      } else {
        res.status(404).json({ errors: "Author not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Create New Author---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Author.init(req.userinfo.tenantcode);

      const authorRecord = await Author.createAuthor(req.body, req.userinfo.id);

      if (!authorRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(201).json(authorRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  //   ---------------------Update Author by Id---------------------------

  router.put("/:id", fetchUser, [], async (req, res) => {



    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const authorId = req.params.id;
    const authorData = req.body;
    Author.init(req.userinfo.tenantcode);
    const updateAuthor = await Author.updateById(
      authorId,
      authorData,
      req.userinfo.id
    );

    if (updateAuthor) {
      return res.status(200).json({ success: true, message: "Record updated successfully" });
    }
    return res.status(200).json(updateAuthor);
  });


  //   ----------------------- Delete Author -------------------

  router.delete("/:id", fetchUser, async (req, res) => {

    Author.init(req.userinfo.tenantcode);
    const result = await Author.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });


  router.get("/books/:id", fetchUser, async (req, res) => {
    try {

      const authorId = req.params.id;
      Author.init(req.userinfo.tenantcode);
      const authorBooks = await Author.findBooksByAuthorId(authorId);
      if (authorBooks) {
        res.status(200).json(authorBooks);
      } else {
        res.status(404).json({ errors: "Author not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });

  app.use(process.env.BASE_API_URL + "/api/authors", router);
};

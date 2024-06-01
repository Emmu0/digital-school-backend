const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Book = require("../models/book.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  //   ---------------------Get All---------------------------

  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.get("/", fetchUser, async (req, res) => {

    Book.init(req.userinfo.tenantcode);
    const books = await Book.findAll();
    if (books) {
      res.status(200).json(books);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  //   ---------------------Get By Id---------------------------
  router.get("/:id", fetchUser, async (req, res) => {
    try {

      const bookId = req.params.id;
      Book.init(req.userinfo.tenantcode);
      const book = await Book.findByBookId(bookId);
      if (book) {
        res.status(200).json(book);
      } else {
        res.status(404).json({ errors: "Book not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Create New Book---------------------------

  router.post("/", fetchUser, [], async (req, res) => {
    try {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Book.init(req.userinfo.tenantcode);

      const bookRecord = await Book.createBook(req.body, req.userinfo.id);

      if (!bookRecord) {
        return res.status(200).json({ message: "This record already exists" });
      }

      return res.status(200).json(bookRecord);
    } catch (error) {
      console.error("Error processing the request:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  //   ---------------------Update Book by Id---------------------------

  router.put("/:id", fetchUser, [], async (req, res) => {

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const bookId = req.params.id;
    const bookData = req.body;
    Book.init(req.userinfo.tenantcode);
    const updateBook = await Book.updateById(
      bookId,
      bookData,
      req.userinfo.id
    );

    if (updateBook) {
      return res.status(200).json({ success: true, message: "Record updated successfully" });
    }
    return res.status(200).json(updateBook);
  });

  router.delete("/:id", fetchUser, async (req, res) => {

    Book.init(req.userinfo.tenantcode);
    const result = await Book.deleteById(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });



  //   ---------------------Get By languageId---------------------------
  router.get("/languageId/:id", fetchUser, async (req, res) => {
    try {

      const languageId = req.params.id;
      Book.init(req.userinfo.tenantcode);
      const book = await Book.findBylanguageId(languageId);
      if (book) {
        res.status(200).json(book);
      } else {
        res.status(404).json({ errors: "Book not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Get By categoryId---------------------------
  router.get("/categoryId/:id", fetchUser, async (req, res) => {
    try {


      const categoryId = req.params.id;
      Book.init(req.userinfo.tenantcode);
      const book = await Book.findByCategoryId(categoryId);
      if (book) {
        res.status(200).json(book);
      } else {
        res.status(404).json({ errors: "Book not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  //   ---------------------Get By PublisherId---------------------------
  router.get("/publisherId/:id", fetchUser, async (req, res) => {
    try {


      const PublisherId = req.params.id;
      Book.init(req.userinfo.tenantcode);
      const book = await Book.findByPublisherId(PublisherId);
      if (book) {
        res.status(200).json(book);
      } else {
        res.status(404).json({ errors: "Book not found" });
      }
    } catch (error) {
      res.status(500).json({ errors: "Internal server error" });
    }
  });


  app.use(process.env.BASE_API_URL + "/api/books", router);
};

const express = require("express");
// const bodyParser = require("body-parser"); /* deprecated */
const cors = require("cors");

const dotenv = require('dotenv').config();

const fileUpload = require('express-fileupload');

const app = express();



var corsOptions = {
  origin: "*"
};

app.use(cors(corsOptions));

app.use(fileUpload());

// parse requests of content-type - application/json
app.use(express.json()); /* bodyParser.json() is deprecated */

// parse requests of content-type - application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: true })); /* bodyParser.urlencoded() is deprecated */

// simple route
app.get("/", (req, res) => {
  res.json({ message: "Welcome to bezkoder application." });
});



require("./app/routes/auth.routes.js")(app);
require("./app/routes/contact.routes.js")(app);
require("./app/routes/students.routes.js")(app);
require("./app/routes/subject.routes.js")(app);//Added by Pathan
require("./app/routes/assignsubjectclass.routes.js")(app);//Added by Pathan
require("./app/routes/section.routes.js")(app);//Added by Pathan
require("./app/routes/class.routes.js")(app);//Added by Pathan
require("./app/routes/faremaster.routes.js")(app); //added by shivam
require("./app/routes/locationmaster.routes.js")(app); //added by shivam
require("./app/routes/transports.routes.js")(app);//added by shivam
require("./app/routes/exam.routes.js")(app); // Added by Pawan Singh Sisodiya
require("./app/routes/session.routes.js")(app); // Added by Pawan Singh Sisodiya
require("./app/routes/result.routes.js")(app);    // Added by Pawan Singh Sisodiya
require("./app/routes/events.routes.js")(app); // Added by Shakib Khan
require("./app/routes/attendance_master.routes.js")(app);
require("./app/routes/attendance.routes.js")(app);
require("./app/routes/attendance_line_item.routes.js")(app);
require("./app/routes/studentaddmission.routes.js")(app);
require("./app/routes/lead.routes.js")(app);
require("./app/routes/previousschool.routes.js")(app);
require("./app/routes/assingment.routes.js")(app);
require("./app/routes/route.routes.js")(app);
require("./app/routes/feesheadmaster.routes.js")(app); //Added by pooja
require("./app/routes/fee_master.routes.js")(app);  //Added by pooja
require("./app/routes/fee_master_installment.routes.js")(app); // Added by Pawan Singh Sisodiya 06-Dec-2023
require("./app/routes/fee_installment_line_items.routes.js")(app); // Added by Pawan Singh Sisodiya 06-Dec-2023
require("./app/routes/fee_deposite.routes.js")(app);
require("./app/routes/role.routes.js")(app);
require("./app/routes/module.routes.js")(app);
require("./app/routes/role_permission.routes.js")(app);
require("./app/routes/syllabusroutes.js")(app);
require("./app/routes/permission.routes.js")(app);
require("./app/routes/timeslot.routes.js")(app); //Added by Pooja Vaishnav
require("./app/routes/timetable.routes.js")(app); //Added by Pooja Vaishnav
require("./app/routes/quick_launcher.routes.js")(app);
require("./app/routes/discount.routes.js")(app); // Added by Pawan Singh Sisodiya 06-Dec-2023
require("./app/routes/discount_line_items.routes.js")(app); // Added by Pawan Singh Sisodiya 25-Mar-2024
require("./app/routes/assign_transport.routes.js")(app); // Added by Pawan Singh Sisodiya 01-Apr-2024
require("./app/routes/student_fee_installments.routes.js")(app); // Added by Pawan Singh Sisodiya 01-Apr-2024
require("./app/routes/book.routes.js")(app); //Added by Yamini
// require("./app/routes/member.routes.js")(app); //Added by Yamini
require("./app/routes/issue.routes.js")(app); //Added by Yamini
require("./app/routes/author.routes.js")(app); //Added by Yamini
require("./app/routes/publisher.routes.js")(app); //Added by Yamini
require("./app/routes/purchase.routes.js")(app); //Added by Yamini
require("./app/routes/supplier.routes.js")(app); //Added by Yamini
require("./app/routes/category.routes.js")(app); //Added by Yamini
require("./app/routes/language.routes.js")(app); //Added by Yamini
require("./app/routes/settings.routes.js")(app); // Added by Pawan Singh Sisodiya 10-May-2024
// set port, listen for requests
//const PORT = process.env.PORT || 3003;
const PORT = 3003;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);

});
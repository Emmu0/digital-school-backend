toc.dat                                                                                             0000600 0004000 0002000 00000407741 14623575605 0014471 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP           /                |            digital_school    15.4    15.4 E              0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                    0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                    0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                    1262    177525    digital_school    DATABASE        CREATE DATABASE digital_school WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_India.1252';
    DROP DATABASE digital_school;
                postgres    false                     2615    177526 
   dwps_ajmer    SCHEMA        CREATE SCHEMA dwps_ajmer;
    DROP SCHEMA dwps_ajmer;
                postgres    false                     2615    177527    sankriti_ajmer    SCHEMA        CREATE SCHEMA sankriti_ajmer;
    DROP SCHEMA sankriti_ajmer;
                postgres    false                     3079    177528 	   uuid-ossp 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    DROP EXTENSION "uuid-ossp";
                   false                    0    0    EXTENSION "uuid-ossp"    COMMENT     W   COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
                        false    2         Ä           1247    177540 
   recordtype    TYPE     q   CREATE TYPE public.recordtype AS ENUM (
    'Parent',
    'Student',
    'Staff',
    'Driver',
    'Teacher'
);
    DROP TYPE public.recordtype;
       public          postgres    false         S           1255    177551    sync_lastmod()    FUNCTION        CREATE FUNCTION public.sync_lastmod() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.lastmodifieddate := NOW();


  RETURN NEW;
END;
$$;
 %   DROP FUNCTION public.sync_lastmod();
       public          postgres    false         T           1255    177552    update_book_copies_on_issue()    FUNCTION     5  CREATE FUNCTION public.update_book_copies_on_issue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update issued count
    UPDATE dwps_ajmer.book b
    SET issued = (
        SELECT SUM(CASE WHEN i.status = 'Issued' THEN 1 ELSE 0 END)
        FROM dwps_ajmer.issue i
        WHERE i.book_id = b.id
    );


    -- Update missing count
    UPDATE dwps_ajmer.book b
    SET missing = (
        SELECT SUM(CASE WHEN i.status = 'Missing' THEN 1 ELSE 0 END)
        FROM dwps_ajmer.issue i
        WHERE i.book_id = b.id
    );


    RETURN NULL;
END;
$$;
 4   DROP FUNCTION public.update_book_copies_on_issue();
       public          postgres    false         U           1255    177553 $   update_book_copies_on_issue_status()    FUNCTION       CREATE FUNCTION public.update_book_copies_on_issue_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status = 'Issued' THEN
        UPDATE dwps_ajmer.book
        SET issued = COALESCE(issued, 0) + 1
        WHERE id = NEW.book_id;
		
    ELSIF NEW.status = 'Returned' THEN
        UPDATE dwps_ajmer.book
        SET issued = COALESCE(issued, 1) - 1
        WHERE id = NEW.book_id AND COALESCE(issued, 0) > 0;
		
    ELSIF NEW.status = 'Missing' THEN
        UPDATE dwps_ajmer.book
        SET missing = COALESCE(missing, 0) + 1,
            issued = COALESCE(issued, 0) - 1
        WHERE id = NEW.book_id AND COALESCE(issued, 0) > 0;
    END IF;


    IF OLD.status = 'Issued' OR OLD.status = 'Missing' THEN
        UPDATE dwps_ajmer.book
        SET issued = COALESCE(issued, 0) - 1
        WHERE id = OLD.book_id AND COALESCE(issued, 0) > 0;
    END IF;


    RETURN NULL;
END;
$$;
 ;   DROP FUNCTION public.update_book_copies_on_issue_status();
       public          postgres    false         Ù            1259    177554    assign_subject    TABLE     Î   CREATE TABLE dwps_ajmer.assign_subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    createdbyid uuid,
    lastmodifiedbyid uuid
);
 &   DROP TABLE dwps_ajmer.assign_subject;
    
   dwps_ajmer         heap    postgres    false    2    7         Ú            1259    177558    assign_transport    TABLE     "  CREATE TABLE dwps_ajmer.assign_transport (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_admission_id uuid,
    transport_id uuid,
    drop_location text,
    fare_id uuid,
    fare_amount numeric,
    distance numeric,
    route_direction text,
    sessionid uuid
);
 (   DROP TABLE dwps_ajmer.assign_transport;
    
   dwps_ajmer         heap    postgres    false    2    7         Û            1259    177564 
   assignment    TABLE        CREATE TABLE dwps_ajmer.assignment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    date date,
    title character varying(255) NOT NULL,
    description text,
    status character varying(50),
    session_id uuid
);
 "   DROP TABLE dwps_ajmer.assignment;
    
   dwps_ajmer         heap    postgres    false    2    7         Ü            1259    177570 
   attendance    TABLE     |  CREATE TABLE dwps_ajmer.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    attendance_master_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    present character varying,
    absent character varying
);
 "   DROP TABLE dwps_ajmer.attendance;
    
   dwps_ajmer         heap    postgres    false    2    7         Ý            1259    177578    attendance_line_item    TABLE     i  CREATE TABLE dwps_ajmer.attendance_line_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    attendance_id uuid,
    date date,
    status character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    data json
);
 ,   DROP TABLE dwps_ajmer.attendance_line_item;
    
   dwps_ajmer         heap    postgres    false    2    7         Þ            1259    177586    attendance_master    TABLE     Ê  CREATE TABLE dwps_ajmer.attendance_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    total_lectures character varying,
    type character varying,
    session_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month character varying,
    year character varying
);
 )   DROP TABLE dwps_ajmer.attendance_master;
    
   dwps_ajmer         heap    postgres    false    2    7         ß            1259    177594    author    TABLE     A  CREATE TABLE dwps_ajmer.author (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    status character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);
    DROP TABLE dwps_ajmer.author;
    
   dwps_ajmer         heap    postgres    false    2    7         à            1259    177602    book    TABLE       CREATE TABLE dwps_ajmer.book (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying,
    author_id uuid,
    isbn character varying,
    category_id uuid,
    publisher_id uuid,
    publish_date date,
    status character varying,
    language_id uuid,
    missing integer DEFAULT 0,
    issued integer DEFAULT 0,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);
    DROP TABLE dwps_ajmer.book;
    
   dwps_ajmer         heap    postgres    false    2    7         á            1259    177612    category    TABLE     H  CREATE TABLE dwps_ajmer.category (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    description character varying
);
     DROP TABLE dwps_ajmer.category;
    
   dwps_ajmer         heap    postgres    false    2    7         â            1259    177620    class    TABLE     Ë  CREATE TABLE dwps_ajmer.class (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    classname character varying NOT NULL,
    maxstrength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    aliasname character varying,
    status character varying,
    session_id uuid,
    session_year character varying
);
    DROP TABLE dwps_ajmer.class;
    
   dwps_ajmer         heap    postgres    false    2    7         ã            1259    177628    class_timing    TABLE     /  CREATE TABLE dwps_ajmer.class_timing (
    id integer NOT NULL,
    name character varying NOT NULL,
    isactive boolean NOT NULL,
    session_id integer NOT NULL,
    created_by uuid,
    modified_by uuid,
    created_date timestamp without time zone,
    modified_date timestamp without time zone
);
 $   DROP TABLE dwps_ajmer.class_timing;
    
   dwps_ajmer         heap    postgres    false    7         ä            1259    177633    class_timing_id_seq    SEQUENCE        CREATE SEQUENCE dwps_ajmer.class_timing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE dwps_ajmer.class_timing_id_seq;
    
   dwps_ajmer          postgres    false    7    227                    0    0    class_timing_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE dwps_ajmer.class_timing_id_seq OWNED BY dwps_ajmer.class_timing.id;
       
   dwps_ajmer          postgres    false    228         å            1259    177634    contactsequence    SEQUENCE     x   CREATE SEQUENCE public.contactsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.contactsequence;
       public          postgres    false         æ            1259    177635    contact    TABLE       CREATE TABLE dwps_ajmer.contact (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    salutation character varying,
    firstname character varying NOT NULL,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    profession character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    spousename character varying,
    qualification character varying,
    description character varying,
    parentid uuid,
    department character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contactno character varying DEFAULT ('CTC-'::text || nextval('public.contactsequence'::regclass)),
    religion character varying,
    lastname character varying,
    recordtype character varying
);
    DROP TABLE dwps_ajmer.contact;
    
   dwps_ajmer         heap    postgres    false    2    229    7         ç            1259    177644    receiptsequence    SEQUENCE     x   CREATE SEQUENCE public.receiptsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.receiptsequence;
       public          postgres    false         è            1259    177645    deposit    TABLE     9  CREATE TABLE dwps_ajmer.deposit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    depositfee numeric,
    dateofdeposit timestamp without time zone DEFAULT now(),
    fromdate date,
    todate date,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    receiptno character varying DEFAULT ('R-'::text || lpad((nextval('public.receiptsequence'::regclass))::text, 4, '0'::text))
);
    DROP TABLE dwps_ajmer.deposit;
    
   dwps_ajmer         heap    postgres    false    2    231    7         é            1259    177655    discount    TABLE       CREATE TABLE dwps_ajmer.discount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    percent numeric(5,2),
    sessionid uuid,
    fee_head_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    amount numeric,
    status text
);
     DROP TABLE dwps_ajmer.discount;
    
   dwps_ajmer         heap    postgres    false    2    7         ê            1259    177663    discount_line_items    TABLE        CREATE TABLE dwps_ajmer.discount_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    discountid uuid
);
 +   DROP TABLE dwps_ajmer.discount_line_items;
    
   dwps_ajmer         heap    postgres    false    2    7         ë            1259    177667    events    TABLE     `  CREATE TABLE dwps_ajmer.events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    event_type character varying(255) NOT NULL,
    start_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_date date NOT NULL,
    end_time time without time zone NOT NULL,
    description text,
    title character varying(255),
    colorcode character varying(255),
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid,
    status character varying
);
    DROP TABLE dwps_ajmer.events;
    
   dwps_ajmer         heap    postgres    false    2    7         ì            1259    177675    exam_schedule    TABLE     °  CREATE TABLE dwps_ajmer.exam_schedule (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_title_id uuid,
    schedule_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration numeric,
    room_no text,
    examinor_id uuid,
    status text,
    subject_id uuid,
    class_id uuid,
    max_marks integer,
    min_marks integer,
    ispractical boolean,
    sessionid uuid
);
 %   DROP TABLE dwps_ajmer.exam_schedule;
    
   dwps_ajmer         heap    postgres    false    2    7         í            1259    177681 
   exam_title    TABLE        CREATE TABLE dwps_ajmer.exam_title (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    status text,
    sessionid uuid
);
 "   DROP TABLE dwps_ajmer.exam_title;
    
   dwps_ajmer         heap    postgres    false    2    7         î            1259    177687    fare_master    TABLE     Â   CREATE TABLE dwps_ajmer.fare_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fare numeric,
    fromdistance numeric,
    todistance numeric,
    status character varying
);
 #   DROP TABLE dwps_ajmer.fare_master;
    
   dwps_ajmer         heap    postgres    false    2    7         ï            1259    177693    fee_deposite    TABLE       CREATE TABLE dwps_ajmer.fee_deposite (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    amount numeric,
    payment_date date,
    payment_method character varying(255),
    late_fee numeric,
    remark character varying(255),
    discount numeric,
    sessionid uuid,
    pending_amount_id uuid,
    status character varying,
    receipt_number integer NOT NULL
);
 $   DROP TABLE dwps_ajmer.fee_deposite;
    
   dwps_ajmer         heap    postgres    false    2    7         ð            1259    177699    fee_deposite_receipt_number_seq    SEQUENCE        CREATE SEQUENCE dwps_ajmer.fee_deposite_receipt_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE dwps_ajmer.fee_deposite_receipt_number_seq;
    
   dwps_ajmer          postgres    false    7    239                    0    0    fee_deposite_receipt_number_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE dwps_ajmer.fee_deposite_receipt_number_seq OWNED BY dwps_ajmer.fee_deposite.receipt_number;
       
   dwps_ajmer          postgres    false    240         ñ            1259    177700    fee_head_master    TABLE     i  CREATE TABLE dwps_ajmer.fee_head_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    order_no numeric
);
 '   DROP TABLE dwps_ajmer.fee_head_master;
    
   dwps_ajmer         heap    postgres    false    2    7         ò            1259    177708    fee_installment_line_items    TABLE     Ö  CREATE TABLE dwps_ajmer.fee_installment_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_head_master_id uuid,
    general_amount numeric,
    obc_amount numeric,
    sc_amount numeric,
    st_amount numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    fee_master_id uuid,
    fee_master_installment_id uuid
);
 2   DROP TABLE dwps_ajmer.fee_installment_line_items;
    
   dwps_ajmer         heap    postgres    false    2    7         ó            1259    177716 
   fee_master    TABLE       CREATE TABLE dwps_ajmer.fee_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    status character varying,
    classid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    type character varying,
    fee_structure character varying,
    sessionid uuid,
    total_general_fees numeric,
    total_obc_fees numeric,
    total_sc_fees numeric,
    total_st_fees numeric
);
 "   DROP TABLE dwps_ajmer.fee_master;
    
   dwps_ajmer         heap    postgres    false    2    7         ô            1259    177724    fee_master_installment    TABLE     ¸  CREATE TABLE dwps_ajmer.fee_master_installment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_master_id uuid,
    sessionid uuid,
    lastmodifieddate timestamp without time zone,
    createddate timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    month character varying,
    obc_fee numeric,
    general_fee numeric,
    sc_fee numeric,
    st_fee numeric
);
 .   DROP TABLE dwps_ajmer.fee_master_installment;
    
   dwps_ajmer         heap    postgres    false    2    7         õ            1259    177730    file    TABLE       CREATE TABLE dwps_ajmer.file (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    filetype character varying NOT NULL,
    filesize bigint,
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    description character varying,
    parentid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid
);
    DROP TABLE dwps_ajmer.file;
    
   dwps_ajmer         heap    postgres    false    2    7         ö            1259    177738    grade_master    TABLE     ²   CREATE TABLE dwps_ajmer.grade_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grade text NOT NULL,
    "from" integer NOT NULL,
    "to" integer NOT NULL
);
 $   DROP TABLE dwps_ajmer.grade_master;
    
   dwps_ajmer         heap    postgres    false    2    7         ÷            1259    177744    bookissuesequence    SEQUENCE     z   CREATE SEQUENCE public.bookissuesequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.bookissuesequence;
       public          postgres    false         ø            1259    177745    issue    TABLE     j  CREATE TABLE dwps_ajmer.issue (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    book_id uuid,
    checkout_date date DEFAULT CURRENT_DATE,
    due_date date,
    return_date date,
    status character varying,
    remark character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    parent_id uuid,
    parent_type character varying,
    book_issue_num character varying DEFAULT ('BI-'::text || lpad((nextval('public.bookissuesequence'::regclass))::text, 5, '0'::text))
);
    DROP TABLE dwps_ajmer.issue;
    
   dwps_ajmer         heap    postgres    false    2    247    7         ù            1259    177755    language    TABLE     H  CREATE TABLE dwps_ajmer.language (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    description character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);
     DROP TABLE dwps_ajmer.language;
    
   dwps_ajmer         heap    postgres    false    2    7         ú            1259    177763    lead    TABLE     ÷  CREATE TABLE dwps_ajmer.lead (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    father_name character varying(100),
    mother_name character varying(100),
    father_qualification character varying(50),
    mother_qualification character varying(50),
    father_occupation character varying(50),
    mother_occupation character varying(50),
    status character varying(50),
    class_id uuid
);
    DROP TABLE dwps_ajmer.lead;
    
   dwps_ajmer         heap    postgres    false    2    7         û            1259    177771    leave    TABLE     -  CREATE TABLE dwps_ajmer.leave (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    contactid uuid,
    fromdate timestamp without time zone,
    enddate timestamp without time zone,
    leavetype character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    studentid uuid
);
    DROP TABLE dwps_ajmer.leave;
    
   dwps_ajmer         heap    postgres    false    2    7         ü            1259    177779    location_master    TABLE     «   CREATE TABLE dwps_ajmer.location_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    location text,
    distance numeric,
    status character varying
);
 '   DROP TABLE dwps_ajmer.location_master;
    
   dwps_ajmer         heap    postgres    false    2    7         ý            1259    177785    pending_amount    TABLE     V  CREATE TABLE dwps_ajmer.pending_amount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    dues numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);
 &   DROP TABLE dwps_ajmer.pending_amount;
    
   dwps_ajmer         heap    postgres    false    2    7         þ            1259    177793    previous_schooling    TABLE     ô  CREATE TABLE dwps_ajmer.previous_schooling (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_name character varying NOT NULL,
    school_address character varying,
    class character varying,
    grade character varying,
    passed_year character varying,
    phone character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    student_id uuid
);
 *   DROP TABLE dwps_ajmer.previous_schooling;
    
   dwps_ajmer         heap    postgres    false    2    7         ÿ            1259    177801 	   publisher    TABLE     D  CREATE TABLE dwps_ajmer.publisher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    status character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);
 !   DROP TABLE dwps_ajmer.publisher;
    
   dwps_ajmer         heap    postgres    false    2    7                     1259    177809    purchase    TABLE     V  CREATE TABLE dwps_ajmer.purchase (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    supplier_id uuid,
    book_id uuid,
    quantity integer,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    date date
);
     DROP TABLE dwps_ajmer.purchase;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177815    quick_launcher    TABLE     ù   CREATE TABLE dwps_ajmer.quick_launcher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    userid uuid NOT NULL,
    sub_module_url character varying,
    icon character varying,
    status character varying,
    name character varying
);
 &   DROP TABLE dwps_ajmer.quick_launcher;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177821    result    TABLE       CREATE TABLE dwps_ajmer.result (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_schedule_id uuid NOT NULL,
    student_addmission_id uuid NOT NULL,
    obtained_marks double precision NOT NULL,
    ispresent boolean,
    grade_master_id uuid NOT NULL
);
    DROP TABLE dwps_ajmer.result;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177825    route    TABLE        CREATE TABLE dwps_ajmer.route (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    locationid uuid,
    transportid uuid,
    order_no text
);
    DROP TABLE dwps_ajmer.route;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177831    section    TABLE       CREATE TABLE dwps_ajmer.section (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    class_id uuid,
    strength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contact_id uuid,
    isactive boolean
);
    DROP TABLE dwps_ajmer.section;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177839    session    TABLE     ¬   CREATE TABLE dwps_ajmer.session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    year text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);
    DROP TABLE dwps_ajmer.session;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177845    settings    TABLE     ÷   CREATE TABLE dwps_ajmer.settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying,
    value character varying,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    createddate date,
    lastmodifieddate date
);
     DROP TABLE dwps_ajmer.settings;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177851    studentsrsequence    SEQUENCE     z   CREATE SEQUENCE public.studentsrsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.studentsrsequence;
       public          postgres    false                    1259    177852    student    TABLE     £  CREATE TABLE dwps_ajmer.student (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    srno character varying DEFAULT ('SR-'::text || lpad((nextval('public.studentsrsequence'::regclass))::text, 5, '0'::text)),
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    description character varying,
    parentid uuid,
    vehicleid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    isrte boolean DEFAULT false,
    permanentstreet character varying,
    permanentcity character varying,
    permanentpostalcode character varying,
    permanentstate character varying,
    permanentcountry character varying,
    section_id uuid,
    session_id uuid,
    category character varying
);
    DROP TABLE dwps_ajmer.student;
    
   dwps_ajmer         heap    postgres    false    2    263    7         	           1259    177862    formsequence    SEQUENCE     u   CREATE SEQUENCE public.formsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.formsequence;
       public          postgres    false         
           1259    177863    student_addmission    TABLE     :  CREATE TABLE dwps_ajmer.student_addmission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    classid uuid,
    dateofaddmission date,
    year character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    formno character varying DEFAULT ('ST-'::text || lpad((nextval('public.formsequence'::regclass))::text, 4, '0'::text)),
    parentid uuid,
    isrte boolean,
    session_id uuid,
    fee_type uuid
);
 *   DROP TABLE dwps_ajmer.student_addmission;
    
   dwps_ajmer         heap    postgres    false    2    265    7                    1259    177872    student_fee_installments    TABLE     S  CREATE TABLE dwps_ajmer.student_fee_installments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    fee_master_installment_id uuid,
    amount numeric,
    deposit_amount numeric,
    deposit_id uuid,
    previous_due numeric,
    status text,
    due_date date,
    orderno integer,
    assign_transport_id uuid,
    transport_fee numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month text,
    session_id uuid
);
 0   DROP TABLE dwps_ajmer.student_fee_installments;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177880    subject    TABLE       CREATE TABLE dwps_ajmer.subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    category character varying,
    type character varying,
    shortname character varying,
    status text
);
    DROP TABLE dwps_ajmer.subject;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177888    subject_teacher    TABLE     H  CREATE TABLE dwps_ajmer.subject_teacher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staffid uuid,
    subjectid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    classid uuid
);
 '   DROP TABLE dwps_ajmer.subject_teacher;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177894    supplier    TABLE     Â  CREATE TABLE dwps_ajmer.supplier (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    contact_person character varying,
    phone character varying,
    email character varying,
    address character varying,
    status character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);
     DROP TABLE dwps_ajmer.supplier;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177902    syllabus    TABLE     Ø   CREATE TABLE dwps_ajmer.syllabus (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    subject_id uuid,
    description text,
    session_id uuid,
    isactive text
);
     DROP TABLE dwps_ajmer.syllabus;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177908 	   time_slot    TABLE     2  CREATE TABLE dwps_ajmer.time_slot (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying(255) NOT NULL,
    start_time character varying,
    end_time character varying,
    status character varying(50),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);
 !   DROP TABLE dwps_ajmer.time_slot;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177914 	   timetable    TABLE       CREATE TABLE dwps_ajmer.timetable (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    contact_id uuid,
    subject_id uuid,
    time_slot_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    section_id uuid,
    start_time character varying,
    end_time character varying,
    status character varying,
    day character varying,
    session_id uuid
);
 !   DROP TABLE dwps_ajmer.timetable;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177922 	   transport    TABLE       CREATE TABLE dwps_ajmer.transport (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    driver_id uuid,
    vehicle_no character varying(20),
    type character varying(50),
    seating_capacity integer,
    status character varying(20),
    end_point uuid
);
 !   DROP TABLE dwps_ajmer.transport;
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177926    user    TABLE     ¡  CREATE TABLE dwps_ajmer."user" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying NOT NULL,
    created_date date,
    last_modified_date date,
    email character varying NOT NULL,
    password character varying NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    phone character varying,
    related_user_id uuid,
    companyid uuid
);
    DROP TABLE dwps_ajmer."user";
    
   dwps_ajmer         heap    postgres    false    2    7                    1259    177932    v_book    VIEW       CREATE VIEW dwps_ajmer.v_book AS
 SELECT book.id,
    book.title,
    book.author_id,
    author.name AS author_name,
    book.category_id,
    category.name AS category_name,
    book.publisher_id,
    publisher.name AS publisher_name,
    book.language_id,
    language.name AS language_name,
    book.isbn,
    book.publish_date,
    book.status,
    book.missing,
    book.issued,
    book.createdbyid,
    book.createddate,
    book.lastmodifiedbyid,
    book.lastmodifieddate,
    book.total_copies,
    (book.total_copies - (book.missing + book.issued)) AS available
   FROM ((((( SELECT book_1.id,
            book_1.title,
            book_1.author_id,
            book_1.category_id,
            book_1.publisher_id,
            book_1.language_id,
            book_1.isbn,
            book_1.publish_date,
            book_1.status,
            book_1.missing,
            book_1.issued,
            book_1.createdbyid,
            book_1.createddate,
            book_1.lastmodifiedbyid,
            book_1.lastmodifieddate,
            ( SELECT COALESCE(sum(p.quantity), (0)::bigint) AS "coalesce"
                   FROM dwps_ajmer.purchase p
                  WHERE (p.book_id = book_1.id)) AS total_copies
           FROM dwps_ajmer.book book_1) book
     JOIN dwps_ajmer.author ON ((book.author_id = author.id)))
     JOIN dwps_ajmer.category ON ((book.category_id = category.id)))
     JOIN dwps_ajmer.publisher ON ((book.publisher_id = publisher.id)))
     JOIN dwps_ajmer.language ON ((book.language_id = language.id)));
    DROP VIEW dwps_ajmer.v_book;
    
   dwps_ajmer          postgres    false    255    255    256    256    224    224    224    224    223    224    223    224    224    224    224    224    224    224    224    224    224    225    225    249    249    7                    1259    177937    v_issue    VIEW       CREATE VIEW dwps_ajmer.v_issue AS
 SELECT i.id,
    i.book_id,
    i.book_issue_num,
    b.title AS book_title,
    i.status,
    i.parent_id,
        CASE
            WHEN ((i.parent_type)::text = 'Student'::text) THEN (((s.firstname)::text || ' '::text) || (s.lastname)::text)
            WHEN ((i.parent_type)::text = 'Staff'::text) THEN (((((c.salutation)::text || ' '::text) || (c.firstname)::text) || ' '::text) || (c.lastname)::text)
            ELSE NULL::text
        END AS parent_name,
        CASE
            WHEN ((i.parent_type)::text = 'Student'::text) THEN (s.srno)::text
            WHEN ((i.parent_type)::text = 'Staff'::text) THEN (c.contactno)::text
            ELSE NULL::text
        END AS parent_eid,
    i.parent_type,
    to_char((i.checkout_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS checkout_date,
    to_char((i.due_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS due_date,
    to_char((i.return_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS return_date,
    i.remark,
    i.createdbyid,
    i.createddate,
    i.lastmodifiedbyid,
    i.lastmodifieddate
   FROM (((dwps_ajmer.issue i
     LEFT JOIN dwps_ajmer.book b ON ((i.book_id = b.id)))
     LEFT JOIN dwps_ajmer.student s ON (((i.parent_id = s.id) AND ((i.parent_type)::text = 'Student'::text))))
     LEFT JOIN dwps_ajmer.contact c ON (((i.parent_id = c.id) AND ((i.parent_type)::text = 'Staff'::text))));
    DROP VIEW dwps_ajmer.v_issue;
    
   dwps_ajmer          postgres    false    248    224    224    230    230    230    230    230    248    248    248    248    248    248    248    248    248    248    248    248    248    264    264    264    264    7                    1259    177942 
   v_purchase    VIEW       CREATE VIEW dwps_ajmer.v_purchase AS
 SELECT p.id,
    p.supplier_id,
    s.name AS supplier_name,
    s.phone AS supplier_phone,
    s.status AS supplier_status,
    s.email AS supplier_email,
    s.contact_person AS supplier_contact_person,
    s.address AS supplier_address,
    p.book_id,
    b.title AS book_title,
    p.quantity,
    to_char((p.date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS date,
    p.createdbyid,
    p.createddate,
    p.lastmodifiedbyid,
    p.lastmodifieddate
   FROM ((dwps_ajmer.purchase p
     LEFT JOIN dwps_ajmer.supplier s ON ((p.supplier_id = s.id)))
     LEFT JOIN dwps_ajmer.book b ON ((p.book_id = b.id)));
 !   DROP VIEW dwps_ajmer.v_purchase;
    
   dwps_ajmer          postgres    false    224    224    256    256    256    256    256    256    256    256    256    270    270    270    270    270    270    270    7                    1259    177947    company    TABLE     7  CREATE TABLE public.company (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    tenantcode character varying NOT NULL,
    userlicenses integer DEFAULT 0 NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    systememail character varying DEFAULT 'admin@spark.indicrm.io'::character varying NOT NULL,
    adminemail character varying DEFAULT 'admin@spark.indicrm.io'::character varying NOT NULL,
    logourl character varying DEFAULT 'https://spark.indicrm.io/logos/client_logo.png'::character varying,
    sidebarbgurl character varying DEFAULT 'https://spark.indicrm.io/logos/sidebar_background.jpg'::character varying,
    city character varying,
    street character varying,
    pincode character varying,
    state character varying,
    country character varying
);
    DROP TABLE public.company;
       public         heap    postgres    false    2                    1259    177959    company_module    TABLE        CREATE TABLE public.company_module (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    companyid uuid,
    moduleid uuid
);
 "   DROP TABLE public.company_module;
       public         heap    postgres    false    2                    1259    177963    module    TABLE     K  CREATE TABLE public.module (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    status character varying,
    api_name character varying(255),
    icon character varying(255),
    url character varying(255),
    icon_type character varying(255),
    parent_module uuid,
    order_no integer
);
    DROP TABLE public.module;
       public         heap    postgres    false    2                    1259    177969 
   permission    TABLE        CREATE TABLE public.permission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    status character varying
);
    DROP TABLE public.permission;
       public         heap    postgres    false    2                    1259    177975    role    TABLE     »   CREATE TABLE public.role (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    description character varying,
    status character varying
);
    DROP TABLE public.role;
       public         heap    postgres    false    2                    1259    177981    role_permission    TABLE     h  CREATE TABLE public.role_permission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    permissionid uuid,
    roleid uuid NOT NULL,
    name character varying,
    moduleid uuid,
    can_read boolean,
    can_edit boolean,
    can_delete boolean,
    status character varying,
    view_all boolean,
    modify_all boolean,
    can_create boolean
);
 #   DROP TABLE public.role_permission;
       public         heap    postgres    false    2                    1259    177987    user    TABLE     7  CREATE TABLE public."user" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    password character varying NOT NULL,
    email character varying,
    companyid uuid,
    userrole character varying,
    phone numeric
);
    DROP TABLE public."user";
       public         heap    postgres    false    2                    1259    177993 	   user_role    TABLE        CREATE TABLE public.user_role (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    userid uuid NOT NULL,
    roleid uuid NOT NULL
);
    DROP TABLE public.user_role;
       public         heap    postgres    false    2                    1259    177997    assign_subject    TABLE     Ò   CREATE TABLE sankriti_ajmer.assign_subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    createdbyid uuid,
    lastmodifiedbyid uuid
);
 *   DROP TABLE sankriti_ajmer.assign_subject;
       sankriti_ajmer         heap    postgres    false    2    8                     1259    178001    assign_transport    TABLE     '  CREATE TABLE sankriti_ajmer.assign_transport (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    transport_id uuid,
    drop_location text,
    fare_id uuid,
    fare_amount numeric,
    distance numeric,
    route_direction text,
    sessionid uuid
);
 ,   DROP TABLE sankriti_ajmer.assign_transport;
       sankriti_ajmer         heap    postgres    false    2    8         !           1259    178007 
   assignment    TABLE     $  CREATE TABLE sankriti_ajmer.assignment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    date date,
    title character varying(255) NOT NULL,
    description text,
    status character varying(50),
    session_id uuid
);
 &   DROP TABLE sankriti_ajmer.assignment;
       sankriti_ajmer         heap    postgres    false    2    8         "           1259    178013 
   attendance    TABLE       CREATE TABLE sankriti_ajmer.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    attendance_master_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    present character varying,
    absent character varying
);
 &   DROP TABLE sankriti_ajmer.attendance;
       sankriti_ajmer         heap    postgres    false    2    8         #           1259    178021    attendance_line_item    TABLE     m  CREATE TABLE sankriti_ajmer.attendance_line_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    attendance_id uuid,
    date date,
    status character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    data json
);
 0   DROP TABLE sankriti_ajmer.attendance_line_item;
       sankriti_ajmer         heap    postgres    false    2    8         $           1259    178029    attendance_master    TABLE     Î  CREATE TABLE sankriti_ajmer.attendance_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    total_lectures character varying,
    type character varying,
    session_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month character varying,
    year character varying
);
 -   DROP TABLE sankriti_ajmer.attendance_master;
       sankriti_ajmer         heap    postgres    false    2    8         %           1259    178037    class    TABLE     Ï  CREATE TABLE sankriti_ajmer.class (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    classname character varying NOT NULL,
    maxstrength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    aliasname character varying,
    status character varying,
    session_id uuid,
    session_year character varying
);
 !   DROP TABLE sankriti_ajmer.class;
       sankriti_ajmer         heap    postgres    false    2    8         &           1259    178045    class_timing    TABLE     3  CREATE TABLE sankriti_ajmer.class_timing (
    id integer NOT NULL,
    name character varying NOT NULL,
    isactive boolean NOT NULL,
    session_id integer NOT NULL,
    created_by uuid,
    modified_by uuid,
    created_date timestamp without time zone,
    modified_date timestamp without time zone
);
 (   DROP TABLE sankriti_ajmer.class_timing;
       sankriti_ajmer         heap    postgres    false    8         '           1259    178050    class_timing_id_seq    SEQUENCE        CREATE SEQUENCE sankriti_ajmer.class_timing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE sankriti_ajmer.class_timing_id_seq;
       sankriti_ajmer          postgres    false    8    294                    0    0    class_timing_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE sankriti_ajmer.class_timing_id_seq OWNED BY sankriti_ajmer.class_timing.id;
          sankriti_ajmer          postgres    false    295         (           1259    178051    contact    TABLE       CREATE TABLE sankriti_ajmer.contact (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    salutation character varying,
    firstname character varying NOT NULL,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    profession character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    spousename character varying,
    qualification character varying,
    description character varying,
    parentid uuid,
    department character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contactno character varying DEFAULT ('CTC-'::text || nextval('public.contactsequence'::regclass)),
    religion character varying,
    lastname character varying,
    recordtype character varying
);
 #   DROP TABLE sankriti_ajmer.contact;
       sankriti_ajmer         heap    postgres    false    2    229    8         )           1259    178060    deposit    TABLE     =  CREATE TABLE sankriti_ajmer.deposit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    depositfee numeric,
    dateofdeposit timestamp without time zone DEFAULT now(),
    fromdate date,
    todate date,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    receiptno character varying DEFAULT ('R-'::text || lpad((nextval('public.receiptsequence'::regclass))::text, 4, '0'::text))
);
 #   DROP TABLE sankriti_ajmer.deposit;
       sankriti_ajmer         heap    postgres    false    2    231    8         *           1259    178070    discount    TABLE       CREATE TABLE sankriti_ajmer.discount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    percent numeric(5,2),
    sessionid uuid,
    fee_head_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    amount numeric,
    status text
);
 $   DROP TABLE sankriti_ajmer.discount;
       sankriti_ajmer         heap    postgres    false    2    8         +           1259    178078    discount_line_items    TABLE     ¡   CREATE TABLE sankriti_ajmer.discount_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    discountid uuid
);
 /   DROP TABLE sankriti_ajmer.discount_line_items;
       sankriti_ajmer         heap    postgres    false    2    8         ,           1259    178082    events    TABLE     d  CREATE TABLE sankriti_ajmer.events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    event_type character varying(255) NOT NULL,
    start_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_date date NOT NULL,
    end_time time without time zone NOT NULL,
    description text,
    title character varying(255),
    colorcode character varying(255),
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid,
    status character varying
);
 "   DROP TABLE sankriti_ajmer.events;
       sankriti_ajmer         heap    postgres    false    2    8         -           1259    178090    exam_schedule    TABLE     µ  CREATE TABLE sankriti_ajmer.exam_schedule (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_title_id uuid,
    schedule_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration numeric,
    room_no text,
    examinor_id uuid,
    status text,
    subject_id uuid,
    class_id uuid,
    max_marks integer,
    min_marks integer,
    ispractical boolean,
    session_id uuid
);
 )   DROP TABLE sankriti_ajmer.exam_schedule;
       sankriti_ajmer         heap    postgres    false    2    8         .           1259    178096 
   exam_title    TABLE         CREATE TABLE sankriti_ajmer.exam_title (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    status text,
    sessionid uuid
);
 &   DROP TABLE sankriti_ajmer.exam_title;
       sankriti_ajmer         heap    postgres    false    2    8         /           1259    178102    fare_master    TABLE     Æ   CREATE TABLE sankriti_ajmer.fare_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fare numeric,
    fromdistance numeric,
    todistance numeric,
    status character varying
);
 '   DROP TABLE sankriti_ajmer.fare_master;
       sankriti_ajmer         heap    postgres    false    2    8         0           1259    178108    fee_deposite    TABLE       CREATE TABLE sankriti_ajmer.fee_deposite (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    amount numeric,
    payment_date date,
    payment_method character varying(255),
    late_fee numeric,
    remark character varying(255),
    discount numeric,
    sessionid uuid,
    pending_amount_id uuid,
    status character varying,
    receipt_number integer NOT NULL
);
 (   DROP TABLE sankriti_ajmer.fee_deposite;
       sankriti_ajmer         heap    postgres    false    2    8         1           1259    178114    fee_deposite_receipt_number_seq    SEQUENCE        CREATE SEQUENCE sankriti_ajmer.fee_deposite_receipt_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 >   DROP SEQUENCE sankriti_ajmer.fee_deposite_receipt_number_seq;
       sankriti_ajmer          postgres    false    8    304                    0    0    fee_deposite_receipt_number_seq    SEQUENCE OWNED BY     s   ALTER SEQUENCE sankriti_ajmer.fee_deposite_receipt_number_seq OWNED BY sankriti_ajmer.fee_deposite.receipt_number;
          sankriti_ajmer          postgres    false    305         2           1259    178115    fee_head_master    TABLE     m  CREATE TABLE sankriti_ajmer.fee_head_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    order_no numeric
);
 +   DROP TABLE sankriti_ajmer.fee_head_master;
       sankriti_ajmer         heap    postgres    false    2    8         3           1259    178123    fee_installment_line_items    TABLE     Ú  CREATE TABLE sankriti_ajmer.fee_installment_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_head_master_id uuid,
    general_amount numeric,
    obc_amount numeric,
    sc_amount numeric,
    st_amount numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    fee_master_id uuid,
    fee_master_installment_id uuid
);
 6   DROP TABLE sankriti_ajmer.fee_installment_line_items;
       sankriti_ajmer         heap    postgres    false    2    8         4           1259    178131 
   fee_master    TABLE       CREATE TABLE sankriti_ajmer.fee_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    status character varying,
    classid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    type character varying,
    fee_structure character varying,
    sessionid uuid,
    total_general_fees numeric,
    total_obc_fees numeric,
    total_sc_fees numeric,
    total_st_fees numeric
);
 &   DROP TABLE sankriti_ajmer.fee_master;
       sankriti_ajmer         heap    postgres    false    2    8         5           1259    178139    fee_master_installment    TABLE     ¼  CREATE TABLE sankriti_ajmer.fee_master_installment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_master_id uuid,
    sessionid uuid,
    lastmodifieddate timestamp without time zone,
    createddate timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    month character varying,
    obc_fee numeric,
    general_fee numeric,
    sc_fee numeric,
    st_fee numeric
);
 2   DROP TABLE sankriti_ajmer.fee_master_installment;
       sankriti_ajmer         heap    postgres    false    2    8         6           1259    178145    file    TABLE     £  CREATE TABLE sankriti_ajmer.file (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    filetype character varying NOT NULL,
    filesize bigint,
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    description character varying,
    parentid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid
);
     DROP TABLE sankriti_ajmer.file;
       sankriti_ajmer         heap    postgres    false    2    8         7           1259    178153    grade_master    TABLE     ¶   CREATE TABLE sankriti_ajmer.grade_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grade text NOT NULL,
    "from" integer NOT NULL,
    "to" integer NOT NULL
);
 (   DROP TABLE sankriti_ajmer.grade_master;
       sankriti_ajmer         heap    postgres    false    2    8         8           1259    178159    lead    TABLE     û  CREATE TABLE sankriti_ajmer.lead (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    father_name character varying(100),
    mother_name character varying(100),
    father_qualification character varying(50),
    mother_qualification character varying(50),
    father_occupation character varying(50),
    mother_occupation character varying(50),
    status character varying(50),
    class_id uuid
);
     DROP TABLE sankriti_ajmer.lead;
       sankriti_ajmer         heap    postgres    false    2    8         9           1259    178167    leave    TABLE     1  CREATE TABLE sankriti_ajmer.leave (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    contactid uuid,
    fromdate timestamp without time zone,
    enddate timestamp without time zone,
    leavetype character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    studentid uuid
);
 !   DROP TABLE sankriti_ajmer.leave;
       sankriti_ajmer         heap    postgres    false    2    8         :           1259    178175    location_master    TABLE     ¯   CREATE TABLE sankriti_ajmer.location_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    location text,
    distance numeric,
    status character varying
);
 +   DROP TABLE sankriti_ajmer.location_master;
       sankriti_ajmer         heap    postgres    false    2    8         ;           1259    178181    pending_amount    TABLE     Z  CREATE TABLE sankriti_ajmer.pending_amount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    dues numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);
 *   DROP TABLE sankriti_ajmer.pending_amount;
       sankriti_ajmer         heap    postgres    false    2    8         <           1259    178189    previous_schooling    TABLE     ø  CREATE TABLE sankriti_ajmer.previous_schooling (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_name character varying NOT NULL,
    school_address character varying,
    class character varying,
    grade character varying,
    passed_year character varying,
    phone character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    student_id uuid
);
 .   DROP TABLE sankriti_ajmer.previous_schooling;
       sankriti_ajmer         heap    postgres    false    2    8         =           1259    178197    quick_launcher    TABLE     ý   CREATE TABLE sankriti_ajmer.quick_launcher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    userid uuid NOT NULL,
    sub_module_url character varying,
    icon character varying,
    status character varying,
    name character varying
);
 *   DROP TABLE sankriti_ajmer.quick_launcher;
       sankriti_ajmer         heap    postgres    false    2    8         >           1259    178203    result    TABLE       CREATE TABLE sankriti_ajmer.result (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_schedule_id uuid NOT NULL,
    student_addmission_id uuid NOT NULL,
    obtained_marks double precision NOT NULL,
    ispresent boolean,
    grade_master_id uuid NOT NULL
);
 "   DROP TABLE sankriti_ajmer.result;
       sankriti_ajmer         heap    postgres    false    2    8         ?           1259    178207    route    TABLE        CREATE TABLE sankriti_ajmer.route (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    locationid uuid,
    transportid uuid,
    order_no text
);
 !   DROP TABLE sankriti_ajmer.route;
       sankriti_ajmer         heap    postgres    false    2    8         @           1259    178213    section    TABLE       CREATE TABLE sankriti_ajmer.section (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    class_id uuid,
    strength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contact_id uuid,
    isactive boolean
);
 #   DROP TABLE sankriti_ajmer.section;
       sankriti_ajmer         heap    postgres    false    2    8         A           1259    178221    session    TABLE     °   CREATE TABLE sankriti_ajmer.session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    year text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);
 #   DROP TABLE sankriti_ajmer.session;
       sankriti_ajmer         heap    postgres    false    2    8         B           1259    178227    student    TABLE     §  CREATE TABLE sankriti_ajmer.student (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    srno character varying DEFAULT ('SR-'::text || lpad((nextval('public.studentsrsequence'::regclass))::text, 5, '0'::text)),
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    description character varying,
    parentid uuid,
    vehicleid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    isrte boolean DEFAULT false,
    permanentstreet character varying,
    permanentcity character varying,
    permanentpostalcode character varying,
    permanentstate character varying,
    permanentcountry character varying,
    section_id uuid,
    session_id uuid,
    category character varying
);
 #   DROP TABLE sankriti_ajmer.student;
       sankriti_ajmer         heap    postgres    false    2    263    8         C           1259    178237    student_addmission    TABLE     >  CREATE TABLE sankriti_ajmer.student_addmission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    classid uuid,
    dateofaddmission date,
    year character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    formno character varying DEFAULT ('ST-'::text || lpad((nextval('public.formsequence'::regclass))::text, 4, '0'::text)),
    parentid uuid,
    isrte boolean,
    session_id uuid,
    fee_type uuid
);
 .   DROP TABLE sankriti_ajmer.student_addmission;
       sankriti_ajmer         heap    postgres    false    2    265    8         D           1259    178246    student_fee_installments    TABLE     W  CREATE TABLE sankriti_ajmer.student_fee_installments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    fee_master_installment_id uuid,
    amount numeric,
    deposit_amount numeric,
    deposit_id uuid,
    previous_due numeric,
    status text,
    due_date date,
    orderno integer,
    assign_transport_id uuid,
    transport_fee numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month text,
    session_id uuid
);
 4   DROP TABLE sankriti_ajmer.student_fee_installments;
       sankriti_ajmer         heap    postgres    false    2    8         E           1259    178254    subject    TABLE       CREATE TABLE sankriti_ajmer.subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    category character varying,
    type character varying,
    shortname character varying,
    status text
);
 #   DROP TABLE sankriti_ajmer.subject;
       sankriti_ajmer         heap    postgres    false    2    8         F           1259    178262    subject_teacher    TABLE     L  CREATE TABLE sankriti_ajmer.subject_teacher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staffid uuid,
    subjectid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    classid uuid
);
 +   DROP TABLE sankriti_ajmer.subject_teacher;
       sankriti_ajmer         heap    postgres    false    2    8         G           1259    178268    syllabus    TABLE     Ü   CREATE TABLE sankriti_ajmer.syllabus (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    subject_id uuid,
    description text,
    session_id uuid,
    isactive text
);
 $   DROP TABLE sankriti_ajmer.syllabus;
       sankriti_ajmer         heap    postgres    false    2    8         H           1259    178274 	   time_slot    TABLE     6  CREATE TABLE sankriti_ajmer.time_slot (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying(255) NOT NULL,
    start_time character varying,
    end_time character varying,
    status character varying(50),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);
 %   DROP TABLE sankriti_ajmer.time_slot;
       sankriti_ajmer         heap    postgres    false    2    8         2           2604    178280    class_timing id    DEFAULT     z   ALTER TABLE ONLY dwps_ajmer.class_timing ALTER COLUMN id SET DEFAULT nextval('dwps_ajmer.class_timing_id_seq'::regclass);
 B   ALTER TABLE dwps_ajmer.class_timing ALTER COLUMN id DROP DEFAULT;
    
   dwps_ajmer          postgres    false    228    227         G           2604    178281    fee_deposite receipt_number    DEFAULT        ALTER TABLE ONLY dwps_ajmer.fee_deposite ALTER COLUMN receipt_number SET DEFAULT nextval('dwps_ajmer.fee_deposite_receipt_number_seq'::regclass);
 N   ALTER TABLE dwps_ajmer.fee_deposite ALTER COLUMN receipt_number DROP DEFAULT;
    
   dwps_ajmer          postgres    false    240    239                   0    177554    assign_subject 
   TABLE DATA           e   COPY dwps_ajmer.assign_subject (id, class_id, subject_id, createdbyid, lastmodifiedbyid) FROM stdin;
 
   dwps_ajmer          postgres    false    217       4127.dat            0    177558    assign_transport 
   TABLE DATA           ¡   COPY dwps_ajmer.assign_transport (id, student_admission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) FROM stdin;
 
   dwps_ajmer          postgres    false    218       4128.dat !          0    177564 
   assignment 
   TABLE DATA           p   COPY dwps_ajmer.assignment (id, class_id, subject_id, date, title, description, status, session_id) FROM stdin;
 
   dwps_ajmer          postgres    false    219       4129.dat "          0    177570 
   attendance 
   TABLE DATA              COPY dwps_ajmer.attendance (id, student_id, attendance_master_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, present, absent) FROM stdin;
 
   dwps_ajmer          postgres    false    220       4130.dat #          0    177578    attendance_line_item 
   TABLE DATA              COPY dwps_ajmer.attendance_line_item (id, attendance_id, date, status, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, data) FROM stdin;
 
   dwps_ajmer          postgres    false    221       4131.dat $          0    177586    attendance_master 
   TABLE DATA           ¶   COPY dwps_ajmer.attendance_master (id, class_id, section_id, total_lectures, type, session_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, year) FROM stdin;
 
   dwps_ajmer          postgres    false    222       4132.dat %          0    177594    author 
   TABLE DATA           t   COPY dwps_ajmer.author (id, name, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
 
   dwps_ajmer          postgres    false    223       4133.dat &          0    177602    book 
   TABLE DATA           Ë   COPY dwps_ajmer.book (id, title, author_id, isbn, category_id, publisher_id, publish_date, status, language_id, missing, issued, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
 
   dwps_ajmer          postgres    false    224       4134.dat '          0    177612    category 
   TABLE DATA           {   COPY dwps_ajmer.category (id, name, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, description) FROM stdin;
 
   dwps_ajmer          postgres    false    225       4135.dat (          0    177620    class 
   TABLE DATA           ª   COPY dwps_ajmer.class (id, classname, maxstrength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, aliasname, status, session_id, session_year) FROM stdin;
 
   dwps_ajmer          postgres    false    226       4136.dat )          0    177628    class_timing 
   TABLE DATA              COPY dwps_ajmer.class_timing (id, name, isactive, session_id, created_by, modified_by, created_date, modified_date) FROM stdin;
 
   dwps_ajmer          postgres    false    227       4137.dat ,          0    177635    contact 
   TABLE DATA           S  COPY dwps_ajmer.contact (id, salutation, firstname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, department, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contactno, religion, lastname, recordtype) FROM stdin;
 
   dwps_ajmer          postgres    false    230       4140.dat .          0    177645    deposit 
   TABLE DATA           ·   COPY dwps_ajmer.deposit (id, studentid, depositfee, dateofdeposit, fromdate, todate, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, receiptno) FROM stdin;
 
   dwps_ajmer          postgres    false    232       4142.dat /          0    177655    discount 
   TABLE DATA              COPY dwps_ajmer.discount (id, name, percent, sessionid, fee_head_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, amount, status) FROM stdin;
 
   dwps_ajmer          postgres    false    233       4143.dat 0          0    177663    discount_line_items 
   TABLE DATA           X   COPY dwps_ajmer.discount_line_items (id, student_addmission_id, discountid) FROM stdin;
 
   dwps_ajmer          postgres    false    234       4144.dat 1          0    177667    events 
   TABLE DATA           Ñ   COPY dwps_ajmer.events (id, event_type, start_date, start_time, end_date, end_time, description, title, colorcode, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id, status) FROM stdin;
 
   dwps_ajmer          postgres    false    235       4145.dat 2          0    177675    exam_schedule 
   TABLE DATA           Ï   COPY dwps_ajmer.exam_schedule (id, exam_title_id, schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical, sessionid) FROM stdin;
 
   dwps_ajmer          postgres    false    236       4146.dat 3          0    177681 
   exam_title 
   TABLE DATA           E   COPY dwps_ajmer.exam_title (id, name, status, sessionid) FROM stdin;
 
   dwps_ajmer          postgres    false    237       4147.dat 4          0    177687    fare_master 
   TABLE DATA           U   COPY dwps_ajmer.fare_master (id, fare, fromdistance, todistance, status) FROM stdin;
 
   dwps_ajmer          postgres    false    238       4148.dat 5          0    177693    fee_deposite 
   TABLE DATA           ½   COPY dwps_ajmer.fee_deposite (id, student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status, receipt_number) FROM stdin;
 
   dwps_ajmer          postgres    false    239       4149.dat 7          0    177700    fee_head_master 
   TABLE DATA              COPY dwps_ajmer.fee_head_master (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, order_no) FROM stdin;
 
   dwps_ajmer          postgres    false    241       4151.dat 8          0    177708    fee_installment_line_items 
   TABLE DATA           ê   COPY dwps_ajmer.fee_installment_line_items (id, fee_head_master_id, general_amount, obc_amount, sc_amount, st_amount, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, fee_master_id, fee_master_installment_id) FROM stdin;
 
   dwps_ajmer          postgres    false    242       4152.dat 9          0    177716 
   fee_master 
   TABLE DATA           Ý   COPY dwps_ajmer.fee_master (id, status, classid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, type, fee_structure, sessionid, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees) FROM stdin;
 
   dwps_ajmer          postgres    false    243       4153.dat :          0    177724    fee_master_installment 
   TABLE DATA           Å   COPY dwps_ajmer.fee_master_installment (id, fee_master_id, sessionid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, month, obc_fee, general_fee, sc_fee, st_fee) FROM stdin;
 
   dwps_ajmer          postgres    false    244       4154.dat ;          0    177730    file 
   TABLE DATA              COPY dwps_ajmer.file (id, title, filetype, filesize, createddate, createdbyid, description, parentid, lastmodifieddate, lastmodifiedbyid) FROM stdin;
 
   dwps_ajmer          postgres    false    245       4155.dat <          0    177738    grade_master 
   TABLE DATA           C   COPY dwps_ajmer.grade_master (id, grade, "from", "to") FROM stdin;
 
   dwps_ajmer          postgres    false    246       4156.dat >          0    177745    issue 
   TABLE DATA           Ì   COPY dwps_ajmer.issue (id, book_id, checkout_date, due_date, return_date, status, remark, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, parent_id, parent_type, book_issue_num) FROM stdin;
 
   dwps_ajmer          postgres    false    248       4158.dat ?          0    177755    language 
   TABLE DATA           {   COPY dwps_ajmer.language (id, name, description, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
 
   dwps_ajmer          postgres    false    249       4159.dat @          0    177763    lead 
   TABLE DATA           e  COPY dwps_ajmer.lead (id, firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation, status, class_id) FROM stdin;
 
   dwps_ajmer          postgres    false    250       4160.dat A          0    177771    leave 
   TABLE DATA           ¦   COPY dwps_ajmer.leave (id, contactid, fromdate, enddate, leavetype, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, studentid) FROM stdin;
 
   dwps_ajmer          postgres    false    251       4161.dat B          0    177779    location_master 
   TABLE DATA           M   COPY dwps_ajmer.location_master (id, location, distance, status) FROM stdin;
 
   dwps_ajmer          postgres    false    252       4162.dat C          0    177785    pending_amount 
   TABLE DATA              COPY dwps_ajmer.pending_amount (id, student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
 
   dwps_ajmer          postgres    false    253       4163.dat D          0    177793    previous_schooling 
   TABLE DATA           ½   COPY dwps_ajmer.previous_schooling (id, school_name, school_address, class, grade, passed_year, phone, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, student_id) FROM stdin;
 
   dwps_ajmer          postgres    false    254       4164.dat E          0    177801 	   publisher 
   TABLE DATA           w   COPY dwps_ajmer.publisher (id, name, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
 
   dwps_ajmer          postgres    false    255       4165.dat F          0    177809    purchase 
   TABLE DATA              COPY dwps_ajmer.purchase (id, supplier_id, book_id, quantity, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, date) FROM stdin;
 
   dwps_ajmer          postgres    false    256       4166.dat G          0    177815    quick_launcher 
   TABLE DATA           \   COPY dwps_ajmer.quick_launcher (id, userid, sub_module_url, icon, status, name) FROM stdin;
 
   dwps_ajmer          postgres    false    257       4167.dat H          0    177821    result 
   TABLE DATA           }   COPY dwps_ajmer.result (id, exam_schedule_id, student_addmission_id, obtained_marks, ispresent, grade_master_id) FROM stdin;
 
   dwps_ajmer          postgres    false    258       4168.dat I          0    177825    route 
   TABLE DATA           J   COPY dwps_ajmer.route (id, locationid, transportid, order_no) FROM stdin;
 
   dwps_ajmer          postgres    false    259       4169.dat J          0    177831    section 
   TABLE DATA              COPY dwps_ajmer.section (id, name, class_id, strength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contact_id, isactive) FROM stdin;
 
   dwps_ajmer          postgres    false    260       4170.dat K          0    177839    session 
   TABLE DATA           C   COPY dwps_ajmer.session (id, year, startdate, enddate) FROM stdin;
 
   dwps_ajmer          postgres    false    261       4171.dat L          0    177845    settings 
   TABLE DATA           t   COPY dwps_ajmer.settings (id, key, value, createdbyid, lastmodifiedbyid, createddate, lastmodifieddate) FROM stdin;
 
   dwps_ajmer          postgres    false    262       4172.dat N          0    177852    student 
   TABLE DATA             COPY dwps_ajmer.student (id, firstname, lastname, srno, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, parentid, vehicleid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, isrte, permanentstreet, permanentcity, permanentpostalcode, permanentstate, permanentcountry, section_id, session_id, category) FROM stdin;
 
   dwps_ajmer          postgres    false    264       4174.dat P          0    177863    student_addmission 
   TABLE DATA           Í   COPY dwps_ajmer.student_addmission (id, studentid, classid, dateofaddmission, year, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, formno, parentid, isrte, session_id, fee_type) FROM stdin;
 
   dwps_ajmer          postgres    false    266       4176.dat Q          0    177872    student_fee_installments 
   TABLE DATA           .  COPY dwps_ajmer.student_fee_installments (id, student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, session_id) FROM stdin;
 
   dwps_ajmer          postgres    false    267       4177.dat R          0    177880    subject 
   TABLE DATA              COPY dwps_ajmer.subject (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, category, type, shortname, status) FROM stdin;
 
   dwps_ajmer          postgres    false    268       4178.dat S          0    177888    subject_teacher 
   TABLE DATA              COPY dwps_ajmer.subject_teacher (id, staffid, subjectid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, classid) FROM stdin;
 
   dwps_ajmer          postgres    false    269       4179.dat T          0    177894    supplier 
   TABLE DATA              COPY dwps_ajmer.supplier (id, name, contact_person, phone, email, address, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
 
   dwps_ajmer          postgres    false    270       4180.dat U          0    177902    syllabus 
   TABLE DATA           o   COPY dwps_ajmer.syllabus (id, class_id, section_id, subject_id, description, session_id, isactive) FROM stdin;
 
   dwps_ajmer          postgres    false    271       4181.dat V          0    177908 	   time_slot 
   TABLE DATA           z   COPY dwps_ajmer.time_slot (id, type, start_time, end_time, status, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
 
   dwps_ajmer          postgres    false    272       4182.dat W          0    177914 	   timetable 
   TABLE DATA           Ô   COPY dwps_ajmer.timetable (id, class_id, contact_id, subject_id, time_slot_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, section_id, start_time, end_time, status, day, session_id) FROM stdin;
 
   dwps_ajmer          postgres    false    273       4183.dat X          0    177922 	   transport 
   TABLE DATA           m   COPY dwps_ajmer.transport (id, driver_id, vehicle_no, type, seating_capacity, status, end_point) FROM stdin;
 
   dwps_ajmer          postgres    false    274       4184.dat Y          0    177926    user 
   TABLE DATA              COPY dwps_ajmer."user" (id, type, created_date, last_modified_date, email, password, firstname, lastname, phone, related_user_id, companyid) FROM stdin;
 
   dwps_ajmer          postgres    false    275       4185.dat Z          0    177947    company 
   TABLE DATA           ¦   COPY public.company (id, name, tenantcode, userlicenses, isactive, systememail, adminemail, logourl, sidebarbgurl, city, street, pincode, state, country) FROM stdin;
    public          postgres    false    279       4186.dat [          0    177959    company_module 
   TABLE DATA           A   COPY public.company_module (id, companyid, moduleid) FROM stdin;
    public          postgres    false    280       4187.dat \          0    177963    module 
   TABLE DATA           k   COPY public.module (id, name, status, api_name, icon, url, icon_type, parent_module, order_no) FROM stdin;
    public          postgres    false    281       4188.dat ]          0    177969 
   permission 
   TABLE DATA           6   COPY public.permission (id, name, status) FROM stdin;
    public          postgres    false    282       4189.dat ^          0    177975    role 
   TABLE DATA           =   COPY public.role (id, name, description, status) FROM stdin;
    public          postgres    false    283       4190.dat _          0    177981    role_permission 
   TABLE DATA              COPY public.role_permission (id, permissionid, roleid, name, moduleid, can_read, can_edit, can_delete, status, view_all, modify_all, can_create) FROM stdin;
    public          postgres    false    284       4191.dat `          0    177987    user 
   TABLE DATA           f   COPY public."user" (id, firstname, lastname, password, email, companyid, userrole, phone) FROM stdin;
    public          postgres    false    285       4192.dat a          0    177993 	   user_role 
   TABLE DATA           7   COPY public.user_role (id, userid, roleid) FROM stdin;
    public          postgres    false    286       4193.dat b          0    177997    assign_subject 
   TABLE DATA           i   COPY sankriti_ajmer.assign_subject (id, class_id, subject_id, createdbyid, lastmodifiedbyid) FROM stdin;
    sankriti_ajmer          postgres    false    287       4194.dat c          0    178001    assign_transport 
   TABLE DATA           ¦   COPY sankriti_ajmer.assign_transport (id, student_addmission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) FROM stdin;
    sankriti_ajmer          postgres    false    288       4195.dat d          0    178007 
   assignment 
   TABLE DATA           t   COPY sankriti_ajmer.assignment (id, class_id, subject_id, date, title, description, status, session_id) FROM stdin;
    sankriti_ajmer          postgres    false    289       4196.dat e          0    178013 
   attendance 
   TABLE DATA           ¡   COPY sankriti_ajmer.attendance (id, student_id, attendance_master_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, present, absent) FROM stdin;
    sankriti_ajmer          postgres    false    290       4197.dat f          0    178021    attendance_line_item 
   TABLE DATA              COPY sankriti_ajmer.attendance_line_item (id, attendance_id, date, status, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, data) FROM stdin;
    sankriti_ajmer          postgres    false    291       4198.dat g          0    178029    attendance_master 
   TABLE DATA           º   COPY sankriti_ajmer.attendance_master (id, class_id, section_id, total_lectures, type, session_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, year) FROM stdin;
    sankriti_ajmer          postgres    false    292       4199.dat h          0    178037    class 
   TABLE DATA           ®   COPY sankriti_ajmer.class (id, classname, maxstrength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, aliasname, status, session_id, session_year) FROM stdin;
    sankriti_ajmer          postgres    false    293       4200.dat i          0    178045    class_timing 
   TABLE DATA              COPY sankriti_ajmer.class_timing (id, name, isactive, session_id, created_by, modified_by, created_date, modified_date) FROM stdin;
    sankriti_ajmer          postgres    false    294       4201.dat k          0    178051    contact 
   TABLE DATA           W  COPY sankriti_ajmer.contact (id, salutation, firstname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, department, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contactno, religion, lastname, recordtype) FROM stdin;
    sankriti_ajmer          postgres    false    296       4203.dat l          0    178060    deposit 
   TABLE DATA           »   COPY sankriti_ajmer.deposit (id, studentid, depositfee, dateofdeposit, fromdate, todate, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, receiptno) FROM stdin;
    sankriti_ajmer          postgres    false    297       4204.dat m          0    178070    discount 
   TABLE DATA           £   COPY sankriti_ajmer.discount (id, name, percent, sessionid, fee_head_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, amount, status) FROM stdin;
    sankriti_ajmer          postgres    false    298       4205.dat n          0    178078    discount_line_items 
   TABLE DATA           \   COPY sankriti_ajmer.discount_line_items (id, student_addmission_id, discountid) FROM stdin;
    sankriti_ajmer          postgres    false    299       4206.dat o          0    178082    events 
   TABLE DATA           Õ   COPY sankriti_ajmer.events (id, event_type, start_date, start_time, end_date, end_time, description, title, colorcode, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id, status) FROM stdin;
    sankriti_ajmer          postgres    false    300       4207.dat p          0    178090    exam_schedule 
   TABLE DATA           Ô   COPY sankriti_ajmer.exam_schedule (id, exam_title_id, schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical, session_id) FROM stdin;
    sankriti_ajmer          postgres    false    301       4208.dat q          0    178096 
   exam_title 
   TABLE DATA           I   COPY sankriti_ajmer.exam_title (id, name, status, sessionid) FROM stdin;
    sankriti_ajmer          postgres    false    302       4209.dat r          0    178102    fare_master 
   TABLE DATA           Y   COPY sankriti_ajmer.fare_master (id, fare, fromdistance, todistance, status) FROM stdin;
    sankriti_ajmer          postgres    false    303       4210.dat s          0    178108    fee_deposite 
   TABLE DATA           Á   COPY sankriti_ajmer.fee_deposite (id, student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status, receipt_number) FROM stdin;
    sankriti_ajmer          postgres    false    304       4211.dat u          0    178115    fee_head_master 
   TABLE DATA              COPY sankriti_ajmer.fee_head_master (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, order_no) FROM stdin;
    sankriti_ajmer          postgres    false    306       4213.dat v          0    178123    fee_installment_line_items 
   TABLE DATA           î   COPY sankriti_ajmer.fee_installment_line_items (id, fee_head_master_id, general_amount, obc_amount, sc_amount, st_amount, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, fee_master_id, fee_master_installment_id) FROM stdin;
    sankriti_ajmer          postgres    false    307       4214.dat w          0    178131 
   fee_master 
   TABLE DATA           á   COPY sankriti_ajmer.fee_master (id, status, classid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, type, fee_structure, sessionid, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees) FROM stdin;
    sankriti_ajmer          postgres    false    308       4215.dat x          0    178139    fee_master_installment 
   TABLE DATA           É   COPY sankriti_ajmer.fee_master_installment (id, fee_master_id, sessionid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, month, obc_fee, general_fee, sc_fee, st_fee) FROM stdin;
    sankriti_ajmer          postgres    false    309       4216.dat y          0    178145    file 
   TABLE DATA              COPY sankriti_ajmer.file (id, title, filetype, filesize, createddate, createdbyid, description, parentid, lastmodifieddate, lastmodifiedbyid) FROM stdin;
    sankriti_ajmer          postgres    false    310       4217.dat z          0    178153    grade_master 
   TABLE DATA           G   COPY sankriti_ajmer.grade_master (id, grade, "from", "to") FROM stdin;
    sankriti_ajmer          postgres    false    311       4218.dat {          0    178159    lead 
   TABLE DATA           i  COPY sankriti_ajmer.lead (id, firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation, status, class_id) FROM stdin;
    sankriti_ajmer          postgres    false    312       4219.dat |          0    178167    leave 
   TABLE DATA           ª   COPY sankriti_ajmer.leave (id, contactid, fromdate, enddate, leavetype, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, studentid) FROM stdin;
    sankriti_ajmer          postgres    false    313       4220.dat }          0    178175    location_master 
   TABLE DATA           Q   COPY sankriti_ajmer.location_master (id, location, distance, status) FROM stdin;
    sankriti_ajmer          postgres    false    314       4221.dat ~          0    178181    pending_amount 
   TABLE DATA              COPY sankriti_ajmer.pending_amount (id, student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
    sankriti_ajmer          postgres    false    315       4222.dat           0    178189    previous_schooling 
   TABLE DATA           Á   COPY sankriti_ajmer.previous_schooling (id, school_name, school_address, class, grade, passed_year, phone, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, student_id) FROM stdin;
    sankriti_ajmer          postgres    false    316       4223.dat           0    178197    quick_launcher 
   TABLE DATA           `   COPY sankriti_ajmer.quick_launcher (id, userid, sub_module_url, icon, status, name) FROM stdin;
    sankriti_ajmer          postgres    false    317       4224.dat           0    178203    result 
   TABLE DATA              COPY sankriti_ajmer.result (id, exam_schedule_id, student_addmission_id, obtained_marks, ispresent, grade_master_id) FROM stdin;
    sankriti_ajmer          postgres    false    318       4225.dat           0    178207    route 
   TABLE DATA           N   COPY sankriti_ajmer.route (id, locationid, transportid, order_no) FROM stdin;
    sankriti_ajmer          postgres    false    319       4226.dat           0    178213    section 
   TABLE DATA              COPY sankriti_ajmer.section (id, name, class_id, strength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contact_id, isactive) FROM stdin;
    sankriti_ajmer          postgres    false    320       4227.dat           0    178221    session 
   TABLE DATA           G   COPY sankriti_ajmer.session (id, year, startdate, enddate) FROM stdin;
    sankriti_ajmer          postgres    false    321       4228.dat           0    178227    student 
   TABLE DATA             COPY sankriti_ajmer.student (id, firstname, lastname, srno, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, parentid, vehicleid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, isrte, permanentstreet, permanentcity, permanentpostalcode, permanentstate, permanentcountry, section_id, session_id, category) FROM stdin;
    sankriti_ajmer          postgres    false    322       4229.dat           0    178237    student_addmission 
   TABLE DATA           Ñ   COPY sankriti_ajmer.student_addmission (id, studentid, classid, dateofaddmission, year, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, formno, parentid, isrte, session_id, fee_type) FROM stdin;
    sankriti_ajmer          postgres    false    323       4230.dat           0    178246    student_fee_installments 
   TABLE DATA           2  COPY sankriti_ajmer.student_fee_installments (id, student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, session_id) FROM stdin;
    sankriti_ajmer          postgres    false    324       4231.dat           0    178254    subject 
   TABLE DATA              COPY sankriti_ajmer.subject (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, category, type, shortname, status) FROM stdin;
    sankriti_ajmer          postgres    false    325       4232.dat           0    178262    subject_teacher 
   TABLE DATA              COPY sankriti_ajmer.subject_teacher (id, staffid, subjectid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, classid) FROM stdin;
    sankriti_ajmer          postgres    false    326       4233.dat           0    178268    syllabus 
   TABLE DATA           s   COPY sankriti_ajmer.syllabus (id, class_id, section_id, subject_id, description, session_id, isactive) FROM stdin;
    sankriti_ajmer          postgres    false    327       4234.dat           0    178274 	   time_slot 
   TABLE DATA           ~   COPY sankriti_ajmer.time_slot (id, type, start_time, end_time, status, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
    sankriti_ajmer          postgres    false    328       4235.dat            0    0    class_timing_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('dwps_ajmer.class_timing_id_seq', 2, true);
       
   dwps_ajmer          postgres    false    228                    0    0    fee_deposite_receipt_number_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('dwps_ajmer.fee_deposite_receipt_number_seq', 1001, false);
       
   dwps_ajmer          postgres    false    240                    0    0    bookissuesequence    SEQUENCE SET     @   SELECT pg_catalog.setval('public.bookissuesequence', 1, false);
          public          postgres    false    247                    0    0    contactsequence    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.contactsequence', 304, true);
          public          postgres    false    229                    0    0    formsequence    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.formsequence', 42, true);
          public          postgres    false    265                    0    0    receiptsequence    SEQUENCE SET     >   SELECT pg_catalog.setval('public.receiptsequence', 19, true);
          public          postgres    false    231                    0    0    studentsrsequence    SEQUENCE SET     @   SELECT pg_catalog.setval('public.studentsrsequence', 29, true);
          public          postgres    false    263                    0    0    class_timing_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('sankriti_ajmer.class_timing_id_seq', 1, false);
          sankriti_ajmer          postgres    false    295                    0    0    fee_deposite_receipt_number_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('sankriti_ajmer.fee_deposite_receipt_number_seq', 1, false);
          sankriti_ajmer          postgres    false    305         ÿ           2606    178283 &   assign_transport assign_transport_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY dwps_ajmer.assign_transport
    ADD CONSTRAINT assign_transport_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY dwps_ajmer.assign_transport DROP CONSTRAINT assign_transport_pkey;
    
   dwps_ajmer            postgres    false    218                    2606    178285    assignment assignment_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY dwps_ajmer.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY dwps_ajmer.assignment DROP CONSTRAINT assignment_pkey;
    
   dwps_ajmer            postgres    false    219         ý           2606    178287 !   assign_subject assignsubject_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY dwps_ajmer.assign_subject
    ADD CONSTRAINT assignsubject_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY dwps_ajmer.assign_subject DROP CONSTRAINT assignsubject_pkey;
    
   dwps_ajmer            postgres    false    217                    2606    178289 .   attendance_line_item attendance_line_item_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY dwps_ajmer.attendance_line_item
    ADD CONSTRAINT attendance_line_item_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY dwps_ajmer.attendance_line_item DROP CONSTRAINT attendance_line_item_pkey;
    
   dwps_ajmer            postgres    false    221                    2606    178291 (   attendance_master attendance_master_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY dwps_ajmer.attendance_master
    ADD CONSTRAINT attendance_master_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY dwps_ajmer.attendance_master DROP CONSTRAINT attendance_master_pkey;
    
   dwps_ajmer            postgres    false    222                    2606    178293    attendance attendance_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY dwps_ajmer.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY dwps_ajmer.attendance DROP CONSTRAINT attendance_pkey;
    
   dwps_ajmer            postgres    false    220         	           2606    178295    author author_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY dwps_ajmer.author
    ADD CONSTRAINT author_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY dwps_ajmer.author DROP CONSTRAINT author_pkey;
    
   dwps_ajmer            postgres    false    223                    2606    178297    book book_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY dwps_ajmer.book
    ADD CONSTRAINT book_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY dwps_ajmer.book DROP CONSTRAINT book_pkey;
    
   dwps_ajmer            postgres    false    224                    2606    178299    category category_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.category DROP CONSTRAINT category_pkey;
    
   dwps_ajmer            postgres    false    225                    2606    178301    class class_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY dwps_ajmer.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY dwps_ajmer.class DROP CONSTRAINT class_pkey;
    
   dwps_ajmer            postgres    false    226                    2606    178303    class_timing class_timing_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY dwps_ajmer.class_timing
    ADD CONSTRAINT class_timing_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY dwps_ajmer.class_timing DROP CONSTRAINT class_timing_pkey;
    
   dwps_ajmer            postgres    false    227                    2606    178305    contact contact_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY dwps_ajmer.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY dwps_ajmer.contact DROP CONSTRAINT contact_pkey;
    
   dwps_ajmer            postgres    false    230                    2606    178307    deposit deposit_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY dwps_ajmer.deposit
    ADD CONSTRAINT deposit_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY dwps_ajmer.deposit DROP CONSTRAINT deposit_pkey;
    
   dwps_ajmer            postgres    false    232                    2606    178309 ,   discount_line_items discount_line_items_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY dwps_ajmer.discount_line_items
    ADD CONSTRAINT discount_line_items_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY dwps_ajmer.discount_line_items DROP CONSTRAINT discount_line_items_pkey;
    
   dwps_ajmer            postgres    false    234                    2606    178311    discount discount_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.discount
    ADD CONSTRAINT discount_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.discount DROP CONSTRAINT discount_pkey;
    
   dwps_ajmer            postgres    false    233                    2606    178313    events events_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY dwps_ajmer.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY dwps_ajmer.events DROP CONSTRAINT events_pkey;
    
   dwps_ajmer            postgres    false    235                    2606    178315     exam_schedule exam_schedule_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY dwps_ajmer.exam_schedule DROP CONSTRAINT exam_schedule_pkey;
    
   dwps_ajmer            postgres    false    236                    2606    178317    exam_title exam_title_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY dwps_ajmer.exam_title
    ADD CONSTRAINT exam_title_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY dwps_ajmer.exam_title DROP CONSTRAINT exam_title_pkey;
    
   dwps_ajmer            postgres    false    237         !           2606    178319    fare_master fare_master_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY dwps_ajmer.fare_master
    ADD CONSTRAINT fare_master_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY dwps_ajmer.fare_master DROP CONSTRAINT fare_master_pkey;
    
   dwps_ajmer            postgres    false    238         #           2606    178321    fee_deposite fee_deposite_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY dwps_ajmer.fee_deposite
    ADD CONSTRAINT fee_deposite_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY dwps_ajmer.fee_deposite DROP CONSTRAINT fee_deposite_pkey;
    
   dwps_ajmer            postgres    false    239         %           2606    178323 $   fee_head_master fee_head_master_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY dwps_ajmer.fee_head_master
    ADD CONSTRAINT fee_head_master_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY dwps_ajmer.fee_head_master DROP CONSTRAINT fee_head_master_pkey;
    
   dwps_ajmer            postgres    false    241         '           2606    178325 :   fee_installment_line_items fee_installment_line_items_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY dwps_ajmer.fee_installment_line_items
    ADD CONSTRAINT fee_installment_line_items_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY dwps_ajmer.fee_installment_line_items DROP CONSTRAINT fee_installment_line_items_pkey;
    
   dwps_ajmer            postgres    false    242         +           2606    178327 1   fee_master_installment fee_master_line_items_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY dwps_ajmer.fee_master_installment
    ADD CONSTRAINT fee_master_line_items_pkey PRIMARY KEY (id);
 _   ALTER TABLE ONLY dwps_ajmer.fee_master_installment DROP CONSTRAINT fee_master_line_items_pkey;
    
   dwps_ajmer            postgres    false    244         )           2606    178329    fee_master fee_master_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY dwps_ajmer.fee_master
    ADD CONSTRAINT fee_master_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY dwps_ajmer.fee_master DROP CONSTRAINT fee_master_pkey;
    
   dwps_ajmer            postgres    false    243         -           2606    178331    file file_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY dwps_ajmer.file
    ADD CONSTRAINT file_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY dwps_ajmer.file DROP CONSTRAINT file_pkey;
    
   dwps_ajmer            postgres    false    245         /           2606    178333    grade_master grade_master_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY dwps_ajmer.grade_master
    ADD CONSTRAINT grade_master_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY dwps_ajmer.grade_master DROP CONSTRAINT grade_master_pkey;
    
   dwps_ajmer            postgres    false    246         1           2606    178335    issue issue_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY dwps_ajmer.issue
    ADD CONSTRAINT issue_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY dwps_ajmer.issue DROP CONSTRAINT issue_pkey;
    
   dwps_ajmer            postgres    false    248         3           2606    178337    language language_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.language DROP CONSTRAINT language_pkey;
    
   dwps_ajmer            postgres    false    249         5           2606    178339    lead lead_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY dwps_ajmer.lead
    ADD CONSTRAINT lead_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY dwps_ajmer.lead DROP CONSTRAINT lead_pkey;
    
   dwps_ajmer            postgres    false    250         7           2606    178341    leave leave_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY dwps_ajmer.leave
    ADD CONSTRAINT leave_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY dwps_ajmer.leave DROP CONSTRAINT leave_pkey;
    
   dwps_ajmer            postgres    false    251         9           2606    178343 $   location_master location_master_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY dwps_ajmer.location_master
    ADD CONSTRAINT location_master_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY dwps_ajmer.location_master DROP CONSTRAINT location_master_pkey;
    
   dwps_ajmer            postgres    false    252         ;           2606    178345 "   pending_amount pending_amount_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY dwps_ajmer.pending_amount
    ADD CONSTRAINT pending_amount_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY dwps_ajmer.pending_amount DROP CONSTRAINT pending_amount_pkey;
    
   dwps_ajmer            postgres    false    253         =           2606    178347 '   previous_schooling previous_school_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY dwps_ajmer.previous_schooling
    ADD CONSTRAINT previous_school_pkey PRIMARY KEY (id);
 U   ALTER TABLE ONLY dwps_ajmer.previous_schooling DROP CONSTRAINT previous_school_pkey;
    
   dwps_ajmer            postgres    false    254         ?           2606    178349    publisher publisher_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY dwps_ajmer.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY dwps_ajmer.publisher DROP CONSTRAINT publisher_pkey;
    
   dwps_ajmer            postgres    false    255         A           2606    178351    purchase purchase_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.purchase
    ADD CONSTRAINT purchase_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.purchase DROP CONSTRAINT purchase_pkey;
    
   dwps_ajmer            postgres    false    256         C           2606    178353 "   quick_launcher quick_launcher_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY dwps_ajmer.quick_launcher
    ADD CONSTRAINT quick_launcher_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY dwps_ajmer.quick_launcher DROP CONSTRAINT quick_launcher_pkey;
    
   dwps_ajmer            postgres    false    257         E           2606    178355    result result_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY dwps_ajmer.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY dwps_ajmer.result DROP CONSTRAINT result_pkey;
    
   dwps_ajmer            postgres    false    258         G           2606    178357    route route_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY dwps_ajmer.route
    ADD CONSTRAINT route_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY dwps_ajmer.route DROP CONSTRAINT route_pkey;
    
   dwps_ajmer            postgres    false    259         I           2606    178359    section section_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY dwps_ajmer.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY dwps_ajmer.section DROP CONSTRAINT section_pkey;
    
   dwps_ajmer            postgres    false    260         K           2606    178361    session session_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY dwps_ajmer.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY dwps_ajmer.session DROP CONSTRAINT session_pkey;
    
   dwps_ajmer            postgres    false    261         M           2606    178363    settings settings_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.settings DROP CONSTRAINT settings_pkey;
    
   dwps_ajmer            postgres    false    262         S           2606    178365 6   student_fee_installments student_fee_installments_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY dwps_ajmer.student_fee_installments
    ADD CONSTRAINT student_fee_installments_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY dwps_ajmer.student_fee_installments DROP CONSTRAINT student_fee_installments_pkey;
    
   dwps_ajmer            postgres    false    267         O           2606    178367    student student_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY dwps_ajmer.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY dwps_ajmer.student DROP CONSTRAINT student_pkey;
    
   dwps_ajmer            postgres    false    264         Q           2606    178369 (   student_addmission studentaddmision_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY dwps_ajmer.student_addmission
    ADD CONSTRAINT studentaddmision_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY dwps_ajmer.student_addmission DROP CONSTRAINT studentaddmision_pkey;
    
   dwps_ajmer            postgres    false    266         U           2606    178371    subject subject_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY dwps_ajmer.subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY dwps_ajmer.subject DROP CONSTRAINT subject_pkey;
    
   dwps_ajmer            postgres    false    268         W           2606    178373 #   subject_teacher subjectteacher_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY dwps_ajmer.subject_teacher
    ADD CONSTRAINT subjectteacher_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY dwps_ajmer.subject_teacher DROP CONSTRAINT subjectteacher_pkey;
    
   dwps_ajmer            postgres    false    269         Y           2606    178375    supplier supplier_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.supplier DROP CONSTRAINT supplier_pkey;
    
   dwps_ajmer            postgres    false    270         [           2606    178377    syllabus syllabus_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY dwps_ajmer.syllabus
    ADD CONSTRAINT syllabus_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY dwps_ajmer.syllabus DROP CONSTRAINT syllabus_pkey;
    
   dwps_ajmer            postgres    false    271         ]           2606    178379    time_slot timeslot_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY dwps_ajmer.time_slot
    ADD CONSTRAINT timeslot_pkey PRIMARY KEY (id);
 E   ALTER TABLE ONLY dwps_ajmer.time_slot DROP CONSTRAINT timeslot_pkey;
    
   dwps_ajmer            postgres    false    272         _           2606    178381    timetable timetable_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY dwps_ajmer.timetable
    ADD CONSTRAINT timetable_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY dwps_ajmer.timetable DROP CONSTRAINT timetable_pkey;
    
   dwps_ajmer            postgres    false    273         a           2606    178383    transport transport_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY dwps_ajmer.transport
    ADD CONSTRAINT transport_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY dwps_ajmer.transport DROP CONSTRAINT transport_pkey;
    
   dwps_ajmer            postgres    false    274         c           2606    178385    user user_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY dwps_ajmer."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY dwps_ajmer."user" DROP CONSTRAINT user_pkey;
    
   dwps_ajmer            postgres    false    275         e           2606    178387    company company_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.company DROP CONSTRAINT company_pkey;
       public            postgres    false    279         g           2606    178389 !   company_module companymodule_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.company_module
    ADD CONSTRAINT companymodule_pkey PRIMARY KEY (id);
 K   ALTER TABLE ONLY public.company_module DROP CONSTRAINT companymodule_pkey;
       public            postgres    false    280         i           2606    178391    module module_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.module DROP CONSTRAINT module_pkey;
       public            postgres    false    281         k           2606    178393    permission permission_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.permission DROP CONSTRAINT permission_pkey;
       public            postgres    false    282         m           2606    178395    role role_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
       public            postgres    false    283         o           2606    178397 #   role_permission rolepermission_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT rolepermission_pkey PRIMARY KEY (id);
 M   ALTER TABLE ONLY public.role_permission DROP CONSTRAINT rolepermission_pkey;
       public            postgres    false    284         q           2606    178399    user user_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
       public            postgres    false    285         s           2606    178401    user_role userrole_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT userrole_pkey PRIMARY KEY (id);
 A   ALTER TABLE ONLY public.user_role DROP CONSTRAINT userrole_pkey;
       public            postgres    false    286                    2620    178402    issue issue_status_trigger    TRIGGER     ¤   CREATE TRIGGER issue_status_trigger AFTER INSERT OR UPDATE OF status ON dwps_ajmer.issue FOR EACH ROW EXECUTE FUNCTION public.update_book_copies_on_issue_status();
 7   DROP TRIGGER issue_status_trigger ON dwps_ajmer.issue;
    
   dwps_ajmer          postgres    false    341    248    248         ~           2620    178403    attendance sync_lastmod    TRIGGER     x   CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.attendance FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 4   DROP TRIGGER sync_lastmod ON dwps_ajmer.attendance;
    
   dwps_ajmer          postgres    false    339    220                    2620    178404    contact sync_lastmod    TRIGGER     u   CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.contact FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 1   DROP TRIGGER sync_lastmod ON dwps_ajmer.contact;
    
   dwps_ajmer          postgres    false    230    339                    2620    178405    file sync_lastmod    TRIGGER     r   CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.file FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 .   DROP TRIGGER sync_lastmod ON dwps_ajmer.file;
    
   dwps_ajmer          postgres    false    245    339                    2620    178406    lead sync_lastmod    TRIGGER     r   CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.lead FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 .   DROP TRIGGER sync_lastmod ON dwps_ajmer.lead;
    
   dwps_ajmer          postgres    false    339    250                    2620    178407    leave sync_lastmod    TRIGGER     s   CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.leave FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 /   DROP TRIGGER sync_lastmod ON dwps_ajmer.leave;
    
   dwps_ajmer          postgres    false    251    339                    2620    178408    section sync_lastmod    TRIGGER     u   CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.section FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 1   DROP TRIGGER sync_lastmod ON dwps_ajmer.section;
    
   dwps_ajmer          postgres    false    260    339                    2620    178409    author trigger_sync_lastmod    TRIGGER     |   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.author FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 8   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.author;
    
   dwps_ajmer          postgres    false    223    339                    2620    178410    book trigger_sync_lastmod    TRIGGER     z   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.book FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 6   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.book;
    
   dwps_ajmer          postgres    false    224    339                    2620    178411    category trigger_sync_lastmod    TRIGGER     ~   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.category FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 :   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.category;
    
   dwps_ajmer          postgres    false    225    339                    2620    178412    issue trigger_sync_lastmod    TRIGGER     {   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.issue FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 7   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.issue;
    
   dwps_ajmer          postgres    false    339    248                    2620    178413    language trigger_sync_lastmod    TRIGGER     ~   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.language FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 :   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.language;
    
   dwps_ajmer          postgres    false    249    339                    2620    178414    publisher trigger_sync_lastmod    TRIGGER        CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.publisher FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 ;   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.publisher;
    
   dwps_ajmer          postgres    false    255    339                    2620    178415    purchase trigger_sync_lastmod    TRIGGER     ~   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.purchase FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 :   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.purchase;
    
   dwps_ajmer          postgres    false    339    256                    2620    178416    supplier trigger_sync_lastmod    TRIGGER     ~   CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.supplier FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();
 :   DROP TRIGGER trigger_sync_lastmod ON dwps_ajmer.supplier;
    
   dwps_ajmer          postgres    false    339    270                    2620    178417 )   issue trigger_update_book_copies_on_issue    TRIGGER     ¬   CREATE TRIGGER trigger_update_book_copies_on_issue AFTER INSERT OR DELETE OR UPDATE ON dwps_ajmer.issue FOR EACH ROW EXECUTE FUNCTION public.update_book_copies_on_issue();
 F   DROP TRIGGER trigger_update_book_copies_on_issue ON dwps_ajmer.issue;
    
   dwps_ajmer          postgres    false    248    340         t           2606    178418 "   discount discount_fee_head_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.discount
    ADD CONSTRAINT discount_fee_head_id_fkey FOREIGN KEY (fee_head_id) REFERENCES dwps_ajmer.fee_head_master(id);
 P   ALTER TABLE ONLY dwps_ajmer.discount DROP CONSTRAINT discount_fee_head_id_fkey;
    
   dwps_ajmer          postgres    false    3877    241    233         u           2606    178423     discount discount_sessionid_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.discount
    ADD CONSTRAINT discount_sessionid_fkey FOREIGN KEY (sessionid) REFERENCES dwps_ajmer.session(id);
 N   ALTER TABLE ONLY dwps_ajmer.discount DROP CONSTRAINT discount_sessionid_fkey;
    
   dwps_ajmer          postgres    false    233    261    3915         v           2606    178428 ,   exam_schedule exam_schedule_Examinor_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT "exam_schedule_Examinor_id_fkey" FOREIGN KEY (examinor_id) REFERENCES dwps_ajmer.contact(id);
 \   ALTER TABLE ONLY dwps_ajmer.exam_schedule DROP CONSTRAINT "exam_schedule_Examinor_id_fkey";
    
   dwps_ajmer          postgres    false    236    230    3859         w           2606    178433 )   exam_schedule exam_schedule_class_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_class_id_fkey FOREIGN KEY (class_id) REFERENCES dwps_ajmer.class(id);
 W   ALTER TABLE ONLY dwps_ajmer.exam_schedule DROP CONSTRAINT exam_schedule_class_id_fkey;
    
   dwps_ajmer          postgres    false    226    236    3855         x           2606    178438 .   exam_schedule exam_schedule_exam_title_id_fkey    FK CONSTRAINT         ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_exam_title_id_fkey FOREIGN KEY (exam_title_id) REFERENCES dwps_ajmer.exam_title(id);
 \   ALTER TABLE ONLY dwps_ajmer.exam_schedule DROP CONSTRAINT exam_schedule_exam_title_id_fkey;
    
   dwps_ajmer          postgres    false    236    237    3871         y           2606    178443 +   exam_schedule exam_schedule_subject_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES dwps_ajmer.subject(id);
 Y   ALTER TABLE ONLY dwps_ajmer.exam_schedule DROP CONSTRAINT exam_schedule_subject_id_fkey;
    
   dwps_ajmer          postgres    false    3925    268    236         z           2606    178448 #   result result_exam_schedule_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.result
    ADD CONSTRAINT result_exam_schedule_id_fkey FOREIGN KEY (exam_schedule_id) REFERENCES dwps_ajmer.exam_schedule(id);
 Q   ALTER TABLE ONLY dwps_ajmer.result DROP CONSTRAINT result_exam_schedule_id_fkey;
    
   dwps_ajmer          postgres    false    3869    258    236         {           2606    178453 "   result result_grade_master_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.result
    ADD CONSTRAINT result_grade_master_id_fkey FOREIGN KEY (grade_master_id) REFERENCES dwps_ajmer.grade_master(id);
 P   ALTER TABLE ONLY dwps_ajmer.result DROP CONSTRAINT result_grade_master_id_fkey;
    
   dwps_ajmer          postgres    false    246    258    3887         |           2606    178458 "   transport transport_driver_id_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.transport
    ADD CONSTRAINT transport_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES dwps_ajmer.contact(id);
 P   ALTER TABLE ONLY dwps_ajmer.transport DROP CONSTRAINT transport_driver_id_fkey;
    
   dwps_ajmer          postgres    false    274    3859    230         }           2606    178463 "   transport transport_end_point_fkey    FK CONSTRAINT        ALTER TABLE ONLY dwps_ajmer.transport
    ADD CONSTRAINT transport_end_point_fkey FOREIGN KEY (end_point) REFERENCES dwps_ajmer.location_master(id);
 P   ALTER TABLE ONLY dwps_ajmer.transport DROP CONSTRAINT transport_end_point_fkey;
    
   dwps_ajmer          postgres    false    252    274    3897                                       4127.dat                                                                                            0000600 0004000 0002000 00000012372 14623575605 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        e4e072fb-ba3f-4d1f-9738-c20f525f0af6	60795019-968d-409a-80c6-0e5705f6a51f	2637931b-4ace-4547-8245-80f720ac376f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
e7592c48-e9fc-41a5-8687-c48a6e1b4dde	df65972a-3ed4-4db3-92ba-1aed0794f0e0	2637931b-4ace-4547-8245-80f720ac376f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
941b20ed-ba92-47c0-9e12-21bea949fff6	df65972a-3ed4-4db3-92ba-1aed0794f0e0	7cd16451-290f-4fca-b90b-c8a6973f9e6c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
375d25ca-c3e8-4d27-9444-bc5cf371e60b	df65972a-3ed4-4db3-92ba-1aed0794f0e0	fbbb3e61-475d-4129-9f64-f408118d18f5	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
4e3b74ca-66d9-4dd7-82c7-037ca9d23a70	8e6c18b4-0810-4f95-abb0-3a733c613ecb	2637931b-4ace-4547-8245-80f720ac376f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
8ea07a0e-0f9a-433e-aff0-4de44ac22d5a	8e6c18b4-0810-4f95-abb0-3a733c613ecb	7cd16451-290f-4fca-b90b-c8a6973f9e6c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
b41f6742-45cd-4afb-8b6d-7c7d95ea4c86	61724501-a791-40f4-8ab9-ad908af677b9	551a2dd0-27cc-4aa9-8da1-917b52fc02d7	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
e9f3bade-963d-42d0-b40a-aa0f89d9bf61	61724501-a791-40f4-8ab9-ad908af677b9	2637931b-4ace-4547-8245-80f720ac376f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
679ea178-dede-4193-b7d6-97e0d69a8ff7	5bc6f9a6-fa68-46f3-80f0-362a95d4f259	e06efc22-b276-45da-8de0-af656c859697	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
2a60bb6f-6d82-4ba4-bf86-78c6d6ac8dd8	5bc6f9a6-fa68-46f3-80f0-362a95d4f259	2637931b-4ace-4547-8245-80f720ac376f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
df5be6d7-8115-4d5c-a829-9c2120a1665f	265f5e95-f0a3-4750-9e95-9eb1f42fe2fd	89b786ff-0aff-47b6-abff-f81aee5b9601	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
ca139bda-16ce-4eda-b005-4a859882805a	60795019-968d-409a-80c6-0e5705f6a51f	551a2dd0-27cc-4aa9-8da1-917b52fc02d7	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
c8b80d14-da08-4548-8b03-b10d97439f58	6fe5f267-1414-4113-9474-86722189d0e6	fbbb3e61-475d-4129-9f64-f408118d18f5	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
c90f7d53-15b1-423d-a4f6-c424d9a81eb4	6fe5f267-1414-4113-9474-86722189d0e6	7cd16451-290f-4fca-b90b-c8a6973f9e6c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
334e5abe-9084-4285-ba1b-e235bac9d8fe	fe6f8f9d-5e76-47b1-bf21-37e38f96adde	08124c21-c903-4c05-a864-26611bb2cc7c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
90360c3d-39e7-4536-bf35-ad0e5a3eb763	fe6f8f9d-5e76-47b1-bf21-37e38f96adde	551a2dd0-27cc-4aa9-8da1-917b52fc02d7	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
5882c466-2999-4352-89f1-642315877b35	fe6f8f9d-5e76-47b1-bf21-37e38f96adde	7cd16451-290f-4fca-b90b-c8a6973f9e6c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
f1a043ea-69a6-4ba0-81ab-c77c2140c89b	fe6f8f9d-5e76-47b1-bf21-37e38f96adde	2637931b-4ace-4547-8245-80f720ac376f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
b33bf98d-3706-412c-9150-e76818bc4926	d5c4da8b-1b01-426f-8b18-403d9beaf537	08124c21-c903-4c05-a864-26611bb2cc7c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
9ed79331-697e-42a3-ab7c-9ee3cb3bb126	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	e06efc22-b276-45da-8de0-af656c859697	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
71573294-3f19-4d57-b253-291b9819dec8	61724501-a791-40f4-8ab9-ad908af677b9	e06efc22-b276-45da-8de0-af656c859697	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
333a8d67-8221-4e67-85a6-8dfbf066be84	61724501-a791-40f4-8ab9-ad908af677b9	649c49a6-91c2-4659-950f-733b64f556c5	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
7ef48284-eb26-479e-a7b8-df97fcb7320d	61724501-a791-40f4-8ab9-ad908af677b9	08124c21-c903-4c05-a864-26611bb2cc7c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
1c990e08-d369-45b1-984b-c893f6fdfdcc	91aa892b-28e9-4bb7-a466-6c816bc6d429	e06efc22-b276-45da-8de0-af656c859697	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
c2610677-4d5c-475b-8b88-4e1def031f8a	91aa892b-28e9-4bb7-a466-6c816bc6d429	7cd16451-290f-4fca-b90b-c8a6973f9e6c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
6807cb9a-f215-407e-b323-4ec25811a259	91aa892b-28e9-4bb7-a466-6c816bc6d429	08124c21-c903-4c05-a864-26611bb2cc7c	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
7ebb0605-d0f5-4488-8209-1db51f37a9c4	60795019-968d-409a-80c6-0e5705f6a51f	a480699f-b688-4483-bd75-c96ded04beb9	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
33de10c2-b88e-428e-a591-303cf7f1f543	60795019-968d-409a-80c6-0e5705f6a51f	b9d2fb47-617d-4e33-bbfe-17abe5a5c486	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
ae683b94-01a6-4f7d-902c-b4146cc78d40	df65972a-3ed4-4db3-92ba-1aed0794f0e0	b9d2fb47-617d-4e33-bbfe-17abe5a5c486	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3
\.


                                                                                                                                                                                                                                                                      4128.dat                                                                                            0000600 0004000 0002000 00000000575 14623575605 0014274 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        f7603367-1b46-41d2-b75d-c262f50f1431	8977ec2c-2726-4de5-8d3b-1529e6f2d6f2	\N	\N	\N	0	\N	\N	\N
ddcb01b0-75f7-4553-9981-3cae38111968	be399674-30b9-477f-80fd-14fadb3ef231	\N	\N	\N	0	\N	\N	\N
5b6829c5-14d8-41d2-b033-4b7e84da7993	60676c56-310b-4d7f-81aa-000ffba03990	\N	\N	\N	0	\N	\N	\N
a62dee85-c238-4df4-aba5-5b4b1d28f9df	1f11ba98-c468-4d3a-b623-5a7efa1ea86e	\N	\N	\N	0	\N	\N	\N
\.


                                                                                                                                   4129.dat                                                                                            0000600 0004000 0002000 00000001161 14623575605 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        58eb2dc9-66cd-4b8f-93ad-e4bbe2c619d5	60795019-968d-409a-80c6-0e5705f6a51f	08124c21-c903-4c05-a864-26611bb2cc7c	2024-02-14	Complete Chapter 1		assigned	\N
5035a169-1372-47be-9fb8-79030f2d92b6	91aa892b-28e9-4bb7-a466-6c816bc6d429	08124c21-c903-4c05-a864-26611bb2cc7c	2024-02-13	Complete Chapter 2		inprogress	\N
d3965d95-b08f-4e94-8b07-c011b97d642d	60795019-968d-409a-80c6-0e5705f6a51f	649c49a6-91c2-4659-950f-733b64f556c5	2024-02-16	Complete Exercise 1		assigned	\N
6b5cfd35-4283-4140-b6a1-bb8dc2786a53	61724501-a791-40f4-8ab9-ad908af677b9	b9d2fb47-617d-4e33-bbfe-17abe5a5c486	2024-02-18	Complete Chapter 14		assigned	\N
\.


                                                                                                                                                                                                                                                                                                                                                                                                               4130.dat                                                                                            0000600 0004000 0002000 00000003604 14623575605 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        d2d877b4-bf62-42b0-bbac-cbf507804414	e387bd09-05b3-475e-81af-d1d1eefd339d	f4538f20-8c72-4781-ae68-b6ae5317c091	2024-01-18 16:45:46.498543	2023-10-30 18:01:40.236681	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	24	4
7e502e24-38a4-4574-bd99-c0829b7ffe10	cf4b29fc-9cb5-4c21-aa4d-7b708812c36e	f4538f20-8c72-4781-ae68-b6ae5317c091	2024-01-18 16:46:33.770434	2023-11-01 11:42:18.302501	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	57	5
4ca25f09-3b1c-466a-a2ef-0a9a345dec72	69bd2368-e016-4222-a4ef-ecfaf052adb7	f4538f20-8c72-4781-ae68-b6ae5317c091	2024-01-18 16:46:33.915574	2023-10-30 18:02:13.347829	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	36	3
b6dc9d11-75c9-4df6-acaa-c3ba946963e5	83022515-6f4b-46ea-b66e-c8e44928170d	8684f171-c016-46e1-8d79-2eb29ef272a3	2024-01-24 16:53:14.271567	2023-11-06 11:09:25.239754	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3	1
401e3442-b458-41bb-a425-4ccb98fb5fbb	5f8ae198-6bad-4251-b136-c0ac8d080a55	\N	2024-01-24 16:53:43.695538	2023-10-30 18:26:52.85685	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	2	1
ffc64b5c-9b5d-4d27-9a4c-2604466cefae	c0f83244-bd6e-403b-8128-6d5964beb8b2	f4538f20-8c72-4781-ae68-b6ae5317c091	2024-01-24 16:53:43.799015	2023-11-01 11:42:18.302501	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	6	1
74642bf6-9581-4188-a9bb-b8d3a71a1ff2	7838dd4f-ad59-480b-8131-5466e9ed89f8	8684f171-c016-46e1-8d79-2eb29ef272a3	2024-01-24 16:54:05.106979	2023-11-06 11:09:25.08532	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	4	1
66c931d1-5850-4e06-866a-c54b93f6328e	503eab77-e247-421a-8d4a-be6198f3967a	f4538f20-8c72-4781-ae68-b6ae5317c091	2024-01-24 16:54:05.242828	2023-10-27 13:40:33.394052	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	15	7
2ad55bf6-de6c-4fb1-a3d5-b8fed6bafdde	503eab77-e247-421a-8d4a-be6198f3967a	50678b96-bdb3-40a8-9e0d-a0b1ab78485e	2024-04-23 02:51:10.921149	2024-04-23 02:49:57.425983	\N	\N	20	10
\.


                                                                                                                            4131.dat                                                                                            0000600 0004000 0002000 00000010673 14623575605 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2b880a19-87d0-4347-8e0c-ce3186bc830b	d2d877b4-bf62-42b0-bbac-cbf507804414	2023-11-10	present	2023-10-11 00:00:00	2023-10-30 18:26:52.893448	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
889e09c1-dc1a-4b95-903c-5b944a23a57c	7e502e24-38a4-4574-bd99-c0829b7ffe10	2023-11-10	absent	2023-11-01 11:43:16.52693	2023-11-01 11:43:16.52693	\N	\N	\N
557ddeac-f460-438d-a0ee-7b5b2ae07930	74642bf6-9581-4188-a9bb-b8d3a71a1ff2	2023-11-01	present	2023-11-06 11:09:25.154533	2023-11-06 11:09:25.154533	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
4c747855-8408-4b1d-8390-6be04318c18f	b6dc9d11-75c9-4df6-acaa-c3ba946963e5	2023-11-01	present	2023-11-06 11:09:25.266816	2023-11-06 11:09:25.266816	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
c2599669-0f62-444b-977d-7896cb34a84e	4ca25f09-3b1c-466a-a2ef-0a9a345dec72	2023-11-10	present	2023-10-11 00:00:00	2023-10-27 15:45:37.7433	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
d2976d92-96b5-4e29-b58a-cf8804b23c05	401e3442-b458-41bb-a425-4ccb98fb5fbb	2023-11-10	present	2023-10-11 00:00:00	2023-10-31 12:59:55.534859	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
9cbaec7f-51ae-4b47-883e-b510643edb3a	ffc64b5c-9b5d-4d27-9a4c-2604466cefae	2023-11-10	present	2023-11-01 11:43:16.52693	2023-11-01 11:43:16.52693	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
7fb062b8-75a3-4234-a936-282e7f5bfd02	74642bf6-9581-4188-a9bb-b8d3a71a1ff2	2023-11-10	present	2023-11-06 11:33:00.84519	2023-11-06 11:33:00.84519	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
5920049c-5ab6-42bd-a9e1-37deb4852b4e	b6dc9d11-75c9-4df6-acaa-c3ba946963e5	2023-11-10	present	2023-11-06 11:33:01.090166	2023-11-06 11:33:01.090166	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
0bd8cc14-8683-4ae8-9e61-b4fdd8b8b87e	74642bf6-9581-4188-a9bb-b8d3a71a1ff2	2023-11-06	present	2023-11-06 11:45:02.959044	2023-11-06 11:45:02.959044	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
3698d9f4-cc01-4b83-8db2-1e9e71a2d78c	b6dc9d11-75c9-4df6-acaa-c3ba946963e5	2023-11-06	present	2023-11-06 11:45:03.169568	2023-11-06 11:45:03.169568	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
bfb859e4-f851-40ca-98e1-e069ee21054f	74642bf6-9581-4188-a9bb-b8d3a71a1ff2	2023-11-07	present	2023-11-06 11:48:00.035193	2023-11-06 11:48:00.035193	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
a27191b0-39ca-40aa-aadf-6bed665fbebe	66c931d1-5850-4e06-866a-c54b93f6328e	2024-01-19	present	2024-01-18 16:45:46.342139	2024-01-18 16:45:46.342139	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
e772233f-ecc2-491d-9ba2-e4656797703a	d2d877b4-bf62-42b0-bbac-cbf507804414	2024-01-19	absent	2024-01-18 16:45:46.461808	2024-01-18 16:45:46.461808	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
d22fbf9d-b96b-4a08-9d97-819ca6688acb	7e502e24-38a4-4574-bd99-c0829b7ffe10	2024-01-19	present	2024-01-18 16:46:33.714726	2024-01-18 16:46:33.714726	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
1d859d1b-f162-4b04-98d4-b02af0ded912	4ca25f09-3b1c-466a-a2ef-0a9a345dec72	2024-01-19	present	2024-01-18 16:46:33.869887	2024-01-18 16:46:33.869887	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
720a9730-27d7-4fe7-9793-4056fe7cad74	b6dc9d11-75c9-4df6-acaa-c3ba946963e5	2023-11-07	absent	2023-11-06 11:48:00.130248	2023-11-06 11:48:00.130248	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
609835fa-e0bc-47cd-933c-a9c8ceb22c49	401e3442-b458-41bb-a425-4ccb98fb5fbb	2024-01-24	absent	2024-01-24 16:53:43.644586	2024-01-24 16:53:43.644586	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
b93012c8-e30f-4d02-864b-d985af9cb6eb	ffc64b5c-9b5d-4d27-9a4c-2604466cefae	2024-01-24	present	2024-01-24 16:53:43.754576	2024-01-24 16:53:43.754576	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
5773b829-0eb6-4fc8-8550-b63c20397dc6	74642bf6-9581-4188-a9bb-b8d3a71a1ff2	2024-01-24	absent	2024-01-24 16:54:05.049263	2024-01-24 16:54:05.049263	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
3dd11651-b4d0-4029-a740-17dec385510a	66c931d1-5850-4e06-866a-c54b93f6328e	2024-01-24	present	2024-01-24 16:54:05.200868	2024-01-24 16:54:05.200868	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
\.


                                                                     4132.dat                                                                                            0000600 0004000 0002000 00000006146 14623575605 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        c2aa71e3-d6f9-41be-90da-9d7b126d2546	265f5e95-f0a3-4750-9e95-9eb1f42fe2fd	df76e7e5-a14e-4d91-a411-7efa1fff5300	7	monthly	\N	2023-10-27 13:13:30.196544	2023-10-27 13:13:30.196544	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	February	2019
618260a6-ad25-4d2d-b33c-cc40f3c7767c	60795019-968d-409a-80c6-0e5705f6a51f	cd36a2c7-3f37-4320-827b-ab2cf6e6eb29	12	daily	\N	2023-10-30 18:14:40.650626	2023-10-30 18:14:40.650626	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	January	2014
50678b96-bdb3-40a8-9e0d-a0b1ab78485e	91aa892b-28e9-4bb7-a466-6c816bc6d429	df76e7e5-a14e-4d91-a411-7efa1fff5300	50	daily	\N	2023-10-31 12:57:02.295285	2023-10-31 12:57:02.295285	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	September	2025
5f8de60d-476c-40e7-9eb9-4fab1c2c341f	61724501-a791-40f4-8ab9-ad908af677b9	a2d33863-ff92-49de-ab2c-e08f6643d0e4	12	daily	\N	2023-10-30 16:49:54.446943	2023-10-30 16:49:54.446943	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	November	2023
fca7802a-aeea-4086-8012-c616566bfb7f	d5c4da8b-1b01-426f-8b18-403d9beaf537	df76e7e5-a14e-4d91-a411-7efa1fff5300	12	daily	\N	2023-10-27 18:41:49.732143	2023-10-27 18:41:49.732143	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	March	2018
c04172e3-6829-4597-89b2-714da19f317d	5bc6f9a6-fa68-46f3-80f0-362a95d4f259	cd36a2c7-3f37-4320-827b-ab2cf6e6eb29	12	test	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea	2023-10-26 17:54:54.667763	2023-10-26 17:54:54.667763	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	oct	2022
562e952f-10b5-49e5-8166-9a04bb0207db	4494d388-aa05-4193-97de-ddec8562a568	e0fdd79a-927f-4f45-8ca1-61af87a8da6b	12	daily	\N	2023-10-31 16:55:03.807268	2023-10-31 16:55:03.807268	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	July	2018
f4538f20-8c72-4781-ae68-b6ae5317c091	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	b41abc28-7411-482d-b6f3-0a820a262179	78	monthly	\N	2023-10-30 16:03:17.234954	2023-10-30 16:03:17.234954	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	September	2014
039a19b9-268b-47ab-8cec-4fb4a2adabe5	60795019-968d-409a-80c6-0e5705f6a51f	a2d33863-ff92-49de-ab2c-e08f6643d0e4	25	daily	\N	2023-11-06 11:21:26.653173	2023-11-06 11:21:26.653173	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	November	2023
d52b8a9e-7d8e-4e11-9327-0cd3714941ae	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	0cca35dd-db81-48ab-8f86-dd8ad76b6756	25	daily	\N	2023-11-06 11:48:35.322486	2023-11-06 11:48:35.322486	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	January	2023
98961041-9f82-4542-ab11-36d4795465e4	df65972a-3ed4-4db3-92ba-1aed0794f0e0	6b68b517-3d05-4f04-a7e6-fd1ba13d185a	25	daily	\N	2023-11-06 17:54:03.762641	2023-11-06 17:54:03.762641	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	January	2023
8684f171-c016-46e1-8d79-2eb29ef272a3	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	df76e7e5-a14e-4d91-a411-7efa1fff5300	34	daily	\N	2023-10-30 16:02:34.246136	2023-10-30 16:02:34.246136	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	November	2018
\.


                                                                                                                                                                                                                                                                                                                                                                                                                          4133.dat                                                                                            0000600 0004000 0002000 00000000005 14623575605 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4134.dat                                                                                            0000600 0004000 0002000 00000000005 14623575605 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4135.dat                                                                                            0000600 0004000 0002000 00000000005 14623575605 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4136.dat                                                                                            0000600 0004000 0002000 00000005513 14623575605 0014270 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        61724501-a791-40f4-8ab9-ad908af677b9	3rd	31	2023-09-05 11:02:10.715927	2023-09-05 11:02:10.715927	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	third	active	\N	\N
60795019-968d-409a-80c6-0e5705f6a51f	1st	30	2023-06-21 11:20:06.196344	2023-06-21 11:20:06.196344	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	first	active	\N	\N
91aa892b-28e9-4bb7-a466-6c816bc6d429	2nd	23	2023-07-06 19:14:19.78314	2023-07-06 19:14:19.78314	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	second	active	\N	\N
4494d388-aa05-4193-97de-ddec8562a568	9th	\N	2023-10-11 15:44:11.368966	2023-10-11 15:44:11.368966	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ninth	active	\N	\N
265f5e95-f0a3-4750-9e95-9eb1f42fe2fd	8th	\N	2023-10-11 15:43:34.669277	2023-10-11 15:43:34.669277	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	eighth	active	\N	\N
d5c4da8b-1b01-426f-8b18-403d9beaf537	5th	\N	2023-10-11 15:42:44.850834	2023-10-11 15:42:44.850834	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	fifth	active	\N	\N
5bc6f9a6-fa68-46f3-80f0-362a95d4f259	6th	\N	2023-10-10 16:06:22.665998	2023-10-10 16:06:22.665998	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	sixth	active	\N	\N
8e6c18b4-0810-4f95-abb0-3a733c613ecb	10th	30	2023-08-08 10:59:59.49761	2023-08-08 10:59:59.49761	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	tenth	active	\N	\N
6fe5f267-1414-4113-9474-86722189d0e6	12th	2	2023-07-26 12:48:42.076935	2023-07-26 12:48:42.076935	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	twelfth	inactive	\N	\N
10c22f00-1f9b-4946-aed4-4f75e82cf36d	11th	30	2023-08-08 11:00:48.005211	2023-08-08 11:00:48.005211	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	eleventh	active	\N	\N
7deddb11-8155-40a4-bdc4-f885da4632f4	100	\N	2024-02-07 16:25:21.781797	2024-02-07 16:25:21.781797	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	100	inactive	\N	\N
2bd7c20d-a147-46da-8c22-a109dae03ce7	13th	\N	2024-01-18 16:07:10.427497	2024-01-18 16:07:10.427497	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Thirteenth	active	\N	\N
8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	7th	67	2023-07-18 11:23:27.112278	2023-07-18 11:23:27.112278	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	seventh	inactive	\N	\N
df65972a-3ed4-4db3-92ba-1aed0794f0e0	4th	\N	2023-10-10 16:38:24.468604	2023-10-10 16:38:24.468604	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	fourth	inactive	\N	\N
8b37c8d3-ff0f-48c5-b7ae-436707436b32	123th	\N	2024-05-16 10:51:00.953063	2024-05-16 10:51:00.953063	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	dasf	active	\N	\N
\.


                                                                                                                                                                                     4137.dat                                                                                            0000600 0004000 0002000 00000000415 14623575605 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	10:00-11:00	t	1	123e4567-e89b-12d3-a456-426655440000	789e4567-e89b-12d3-a456-426655440000	2023-09-10 10:00:00	2023-09-10 10:00:00
2	11:00-12:00	f	2	234e4567-e89b-12d3-a456-426655440000	890e4567-e89b-12d3-a456-426655440000	2023-09-11 09:30:00	2023-09-11 09:30:00
\.


                                                                                                                                                                                                                                                   4140.dat                                                                                            0000600 0004000 0002000 00000061211 14623575605 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        063df397-2605-458d-8400-d89bc373f6a6	Mr	Bhairav	2014-01-30	Male	bhairav@gmail.com		2424242424	\N	110022	Street no 5	Lucknow	Uttar Pradesh	India	\N	\N	Secondary	\N	\N	\N	2023-10-12 13:18:36.591797	2023-10-09 16:53:25.938807	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-216	Hindu	Singh	Driver
e8e8c15b-d86e-4e75-8674-86ddf95d02c9	Mr	Amit	1995-05-06	Male	amit@gmail.com	111122223333	989909	\N	567876	Street no 4	Jodhpur	Rajasthan	India	\N	\N	B.Ed	\N	\N	\N	2023-10-12 13:19:01.662722	2023-10-12 12:17:38.572668	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-222	Hindu	Jain	Teacher
a1a71e5f-8a9f-49d7-9eac-d89d721a5a73	Mr	Ron	1999-02-04	Male	ron@gmail.com	678956772345	45445667	Not Available	444566	Street no 7	Mumbai	Maharashtra	India	\N	Not Available 	BA	\N	\N	\N	2023-10-12 13:23:59.029304	2023-09-05 10:54:42.684802	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-206	Christian	Viesly	Librarian
696d6e02-611d-4203-a4d1-ad75abdbf567	Mr	Ravi	1999-01-17	Male	ravi@gmail.com		2424242424	\N	305004	Street no 7	Ajmer	Rajasthan	India	\N	\N	B.Com	\N	\N	academic	2023-10-12 13:14:49.416813	2023-09-05 16:16:54.768098	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-213	Hindu	Verma	Admin
28b4d219-14dd-40c0-aa48-e6b2fb5eb631	Mr	Hari	1980-04-23	Male	hari@gmail.com		989909	\N	3456789	Streent no 5	Bengaluru	Karnataka	India	\N	\N	Secondary	\N	\N	\N	2023-10-12 17:47:15.233061	2023-10-12 17:47:15.233061	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-224	Muslim	Narayan	Driver
5aa8eb8b-41e3-4a1c-a91d-dfe59b66cc4e	Mr	Vivan	2023-08-01	Male	\N	634098523095	3790325890	\N	\N	\N	Nashik	Maharashtra	\N	\N	\N	BA Pass	\N	\N	driver	2023-10-10 16:10:29.386205	2023-08-09 15:57:45.302942	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-203	Hindu	Sharma	\N
f8d90a7b-763d-475d-a7e0-27d8348065b7	Mr	Rajesh	2023-05-22	Male	zakir@gmail.com	6436546546	\N	Kuch nhi	\N	\N	\N	\N	\N	\N	Not Available	BA Pass	\N	\N	\N	2023-10-10 16:10:29.386205	2023-08-03 17:50:37.976374	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-197	\N	Test 2	\N
06add514-edec-4985-832d-42a438bcf260	Mr	Manish	\N	Male	zakir@gmail.com	6436546546	\N	Teacher	\N	\N	\N	\N	\N	\N	Not Available	BA Pass	\N	\N	\N	2023-09-22 15:42:29.080143	2023-08-08 12:36:34.468892	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-201	\N	Yadav	Parent_Father
0b65e34d-2673-4f50-9574-d79cdc34e74e	Mrs	Shikha	2023-05-25	Male	zakir@gmail.com	6436546546	\N	Kuch nhi	\N	\N	\N	\N	\N	\N	Not Available	BA Pass	\N	\N	\N	2023-09-22 15:42:52.752455	2023-08-03 18:23:05.646602	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-198	\N	Jain	Parent_Mother
47888890-cfd0-4060-80d6-a13b1e57d361	Mr	Shan	2023-07-18	Male	zakir@gmail.com	4534534	235467	\N	\N	Street	Pune	Maharashtra	India	\N	\N	BA Failed	\N	\N	driver	2023-09-22 15:43:27.633941	2023-08-09 13:13:55.993601	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-202	Hindu	Chaudary	Parent_Guardian
c4d69cfb-9a10-46b4-8ce9-e82d210eadcd	Mr	Bhupender	1993-10-14	Male	bhupendra@gmail.com	643654654689	2134567890	\N	305001	Street no 12	Vijainagar, Ajmer	Rajasthan	India	\N	\N	Secondary	\N	\N	academic	2023-10-12 13:16:58.440495	2023-08-14 13:08:53.72058	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-205	Hindu	Vijayvergiya	Peon
7e4220c3-4283-4aff-a56a-12beaa0c862a	Ms	Nickole	1994-09-01	Female	nickole@gmail.com		55667765	\N	909876	Street no 5	Amritsar	Punjab	India	\N	\N	B.Sc	\N	\N	\N	2023-10-12 13:17:16.953058	2023-10-10 16:33:24.973828	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-218	Hindu	Sharma	Teacher
e668ff8a-cc2b-4aa5-9b15-66d667e046cf	Mr	Vishwas	1986-03-12	Male	vish@gmail.com	643654654633	2424242424	Kuch nhi	13356665	Street no 21	Ballari	Karnataka	India	\N	Not Available 2	Secondary	\N	\N	\N	2023-10-12 13:17:28.776745	2023-08-10 19:11:48.151525	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-204	Hindu	Singh	Security Guard
f53b6968-315f-40dd-99af-bbe8d9653f07	Mr	Akshay	2022-12-30	Male	akshay@gmail.com		989909	Kuch nhi	335009	Street no 5	Surat	Gujarat	India	\N	Not Available 3	BA	\N	\N	\N	2023-10-12 13:17:44.383435	2023-08-03 18:39:20.95843	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-199	Hindu	Kumar	PTI
23b78f9f-fbfe-4e3c-b5b5-effaf60d813d	Ms	Niharika	1993-06-15	Female	niharika@gmail.com		2424242424	\N	305001	Street no 12	Ajmer	Rajasthan	India	\N	\N	MA	\N	\N	\N	2023-10-12 13:17:57.871551	2023-10-11 18:05:40.18934	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-219	Hindu	Verma	Teacher
fcf9308d-c914-4469-a3f3-0734a49e0fce	Mrs	Gitika	1995-02-14	Female	gitika@gmail.com		9900990099	\N	112233	Street no 1	Jaipur	Rajasthan	India	\N	\N	MA	\N	\N	\N	2023-10-12 13:18:17.51189	2023-10-12 11:33:35.049912	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-220	Hindu	Verma	Teacher
f66055ec-634e-4085-9d25-7ab0d704b083	Mr	Nick	2023-09-07	Male	nick@gmail.com		9900990099	\N	90990	Street no 8	Mangaluru	Karnataka	India	\N	\N	M.Ed	\N	\N	\N	2023-10-25 12:13:46.880261	2023-10-10 16:22:08.362698	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-217	Hindu	Sharma	Teacher
742fbd1c-32b7-462e-b73b-dde1c04f588f	Ms	Neha	1993-07-02	Female	neha@gmail.com	111122223333	121212	\N	300789	Street no 3	New Delhi	Delhi	India	\N	\N	B.Ed.	\N	\N	\N	2023-10-25 18:50:45.688362	2023-10-12 12:15:41.641229	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-221	Hindu	Jain	Teacher
a1e84968-c1b9-4678-872f-15cc90208eba	Mr	Farhaan	1990-05-13	Male	farhaan@gmail.com		989909	Kuch nhi	305001	Street no 9	Ajmer	Rajasthan	India	\N	Not Available 2	M.Com	\N	\N	academic	2023-10-25 19:04:05.996398	2023-08-03 16:17:58.859434	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-196	Muslim	Akhtar	Accountant
e9d335db-f40d-47fc-a86a-fde592d264c9	Mr	Kartik	2023-10-18	Male	Kartik@gm.com	781289234567	9646367588	\N	305001	Adarsh NAgar	Delhi	Delhi	India	\N	\N	B.SC	\N	\N	driver	2023-10-30 13:48:59.028317	2023-10-30 13:48:27.491108	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-234	Hindu	Sen singh1223	Driver
0b9ca7a8-cdb5-4e98-b1e1-8ad8e2ecbede	Mr	Chirag	2023-10-07	Male	chirag@gm.com	678787987928	9646367588	\N	305001	Adarsh NAgar	Tiruppur	Tamil Nadu	India	\N	\N	BBA	\N	\N	driver	2023-10-25 18:29:42.975948	2023-10-25 18:22:48.42812	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-230	Sikh	Sharma	Admin
5777fe71-1b1e-4061-9ec1-2d80120f0ec0	Mrs	Saroj	1977-07-08	Male	saroj@gmail.com	456799001111	9876543	\N	435343	Street no 7	Delhi	Delhi	India	\N	\N	PHD	\N	\N	academic	2023-10-26 13:25:10.427897	2023-09-05 15:23:42.150906	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-207	Muslim	Khan	Principal
41d0bb34-d49b-46e3-a15c-e05940234f82	Ms	Rakul	2023-10-15	Male	Rakul@gm.com	678787987923	9646367588	\N	305001	Adarsh NAgar	Ballari	Karnataka	india	\N	\N	B.SC	\N	\N	\N	2023-10-30 13:44:28.032861	2023-10-30 13:42:11.232997	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-233	Hindu	Preet Singh	Teacher
8d377acf-d219-4ca0-8c0b-91726f5f2254	Mr	Vijay	1992-01-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2023-11-06 12:24:20.596544	2023-11-06 12:24:20.596544	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-238	\N	Sharma	Teacher
64af269f-0e02-4f14-a7c3-50a7d74ff57f	Mrs	Shruti	1983-06-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2023-11-06 12:25:08.070083	2023-11-06 12:25:08.070083	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-239	\N	Desai	Teacher
1b75aa46-6b27-494a-a846-7e19215ebd24	Ms	Preeti 	1991-06-07	Female	pt@gmail.com	111122223333	2424242424	\N	17685994	Streent no 15	Mangaluru	Karnataka	India	\N	\N	PHD	\N	\N	\N	2023-11-06 12:30:44.015922	2023-11-06 12:21:13.631871	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-237	Hindu	Tamra	Teacher
53bbafdf-af00-464c-ba1c-ef364c4c5334	\N	Ganesh	1996-02-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	driver	2023-11-06 12:31:37.235938	2023-11-06 12:31:37.235938	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-240	\N	Prasad	Driver
080a91f7-4ea1-4621-94df-0c0ffa493b68	Dr	Shikha	1979-08-16	Female	shikha@gmail.com	111122223328	\N	\N	\N	Street no 12	Jodhpur	Rajasthan	\N	\N	\N	PHD	\N	\N	\N	2023-11-09 16:35:47.310632	2023-10-17 13:49:45.789248	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-226	Hindu	Mathur	Teacher
20d7fc1a-3b91-49d9-871c-d8df13df4591	\N	rte father	\N	\N	rtef@gmail.com	\N	111111	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-01-24 16:45:26.56477	2024-01-24 16:45:26.56477	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-246	\N	test	Parent_Father
9f516eb9-240e-4954-a8ac-e83e4872f4e5	\N	Girish	\N	\N	father@gmail.com	\N	123456	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-01-24 16:35:24.85533	2024-01-24 16:35:24.85533	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-243	\N	Hemnani	Parent_Father
56c71b5a-e37f-40e7-a814-e1173fd463fc	\N	Girisha	\N	\N	girisha@gmail.com	\N	7888645	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-01-24 16:35:24.878975	2024-01-24 16:35:24.878975	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-244	\N	Hemnani	Parent_Mother
22be29d5-671d-4e30-9e5a-b0311c444b38	\N	Guardian	\N	\N	ga@gmail.com	\N	567890	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-01-24 16:35:24.882125	2024-01-24 16:35:24.882125	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-245	\N	Ambani	Parent_Guardian
c8acabd2-9f92-4a99-8f08-336f7effd311	\N	rte mother	\N	\N	rtem@gmail.com	\N	22222	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-01-24 16:45:26.592503	2024-01-24 16:45:26.592503	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-247	\N	test	Parent_Mother
e7e92d7a-d9ba-4727-a9b3-f6c2cd79dd8b	\N	rteguardian	\N	\N	rteg@gmail.com	\N	33333	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-01-24 16:45:26.602259	2024-01-24 16:45:26.602259	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-248	\N	test	Parent_Guardian
4fff8f12-9e0e-4de5-bfd8-f9c5c1b399a5	Mr	Bhairav	2014-01-30	Male	bhairav@gmail.com	\N	2424242424	\N	110022	Street no 5	Lucknow	Uttar Pradesh	India	\N	\N	Secondary	\N	\N	driver	2024-01-25 16:57:14.72438	2024-01-25 16:57:14.72438	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-249	Hindu	Singh	Driver
5583b133-9328-4685-b0b3-195f019d4c8c	\N	Anish	\N	\N	anish@gmail.com	\N	000000000	Engineer	\N	\N	\N	\N	\N	\N	\N	M.Tech	\N	\N	\N	2024-02-09 13:34:48.363564	2024-02-09 13:34:48.363564	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-251	\N	Jain	Parent_Father
5aaef5aa-6e32-4d68-8d19-692bcba2000c	\N	Kanika	\N	\N	kanika@gmail.com	\N	000000000	Engineer	\N	\N	\N	\N	\N	\N	\N	M.Tech	\N	\N	\N	2024-02-09 13:34:48.393227	2024-02-09 13:34:48.393227	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-252	\N	jain	Parent_Mother
52adfbee-07cf-427d-abf3-c523269a1f73	\N	Anish	\N	\N	anish@gmail.com	\N	000000000	Engineer	\N	\N	\N	\N	\N	\N	\N	M.Tech	\N	\N	\N	2024-02-09 13:34:48.402832	2024-02-09 13:34:48.402832	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-253	\N	jain	Parent_Guardian
471b3f48-78d0-436c-8fbe-3feb1360af63	\N	hari	2024-01-09	\N	hari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:11:41.750778	2024-02-12 13:11:41.750778	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-254	\N	n	Driver
a09239c3-6e78-4cdd-8c96-b9957264a380	\N	hari	2024-02-01	\N	hari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:16:03.359752	2024-02-12 13:16:03.359752	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-255	\N	n	Driver
539e32f3-7a3a-4759-ae29-a287fe0ddc34	\N	hari	2024-02-05	\N	hari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:17:53.931471	2024-02-12 13:17:53.931471	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-256	\N	n	Driver
0c2d6ee8-a903-4b0e-9b7a-7200d67cbe6c	\N	hari	2024-02-05	\N	hari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:18:25.498308	2024-02-12 13:18:25.498308	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-257	\N	n	Driver
637602dd-2135-4dd5-add8-3006187ff23f	\N	hari	2024-02-06	\N	hari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:19:16.687477	2024-02-12 13:19:16.687477	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-258	\N	n	Driver
1df13313-4fb6-4c47-a161-d1037821abcc	\N	test	2024-02-05	\N	hari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:20:13.54031	2024-02-12 13:20:13.54031	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-259	\N	hari	Driver
f78c1cc9-a297-4d9c-8fdc-b921972d60fe	\N	test	2024-02-05	\N	hari1@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:20:38.438869	2024-02-12 13:20:38.438869	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-260	\N	hari	Driver
5b7e3019-669c-42ff-be99-08485e36bda7	\N	test	2024-02-05	\N	hari123@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-12 13:21:05.79616	2024-02-12 13:21:05.79616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-261	\N	hari	Driver
33a721b8-b8a3-4572-8f7b-139a692c0e84	\N	Moinuddin	\N	\N	moinuddin@ymail.com	\N	99009900	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-13 13:00:32.725889	2024-02-13 13:00:32.725889	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-262	\N	Khan	Parent_Father
3a4e7346-041f-48a8-8dc0-74655f119b44	\N	Ishana	\N	\N	ishana@ymail.com	\N	99009900	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-13 13:00:32.748071	2024-02-13 13:00:32.748071	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-263	\N	Khan	Parent_Mother
3657e2ef-e12c-4077-a313-6b4971c13049	\N	gaurdian	\N	\N	guardiankhan@gmail.com	\N	99009900	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-13 13:00:32.755415	2024-02-13 13:00:32.755415	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-264	\N	khan	Parent_Guardian
10d3fc9b-da65-4508-905e-11b81e61d1d2	\N	Yashraj	\N	\N	yashraj@gmail.com	\N	899809078	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 16:06:00.060875	2024-02-20 16:06:00.060875	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-265	\N	Verma	Parent_Father
08d87fc0-333c-42d9-8b9f-a9986b3b9585	\N	Vardika	\N	\N	verdika@gmail.com	\N	899809078	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 16:06:00.089971	2024-02-20 16:06:00.089971	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-266	\N	Verma	Parent_Mother
249969c5-1553-4fb7-9fde-48d7acdbdf40	\N	Yashraj	\N	\N	yashraj@gmail.com	\N	899809078	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 16:06:00.100579	2024-02-20 16:06:00.100579	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-267	\N	Verma	Parent_Guardian
8df9bb87-592d-4502-a0d0-f15943af5742	\N	Ravi	\N	\N	ravit@gmail.com	\N	9900990011	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 18:44:52.451393	2024-02-20 18:44:52.451393	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-268	\N	Tripathi	Parent_Father
1c094f3d-7488-4e2d-a61f-09888cf0cff1	\N	Vanshita	\N	\N	vanshita@gmail.com	\N	9900990011	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 18:44:52.472988	2024-02-20 18:44:52.472988	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-269	\N	Tripathi	Parent_Mother
02eee8fa-14e3-4040-8dcb-f1d9b96cad7c	\N	Ravi	\N	\N	ravit@gmail.com	\N	9900990011	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 18:44:52.478866	2024-02-20 18:44:52.478866	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-270	\N	Tripathi	Parent_Guardian
f72e8055-0369-4514-b889-b9be885f1c46	\N	Mishant	\N	\N	mishant@gmail.com	\N	0100636312	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 18:52:39.326497	2024-02-20 18:52:39.326497	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-271	\N	Verma	Parent_Father
d7de9b95-7b97-4c7e-94ee-a9de55b03b89	\N	Suhana	\N	\N	suhana@gmail.com	\N	0100636312	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 18:52:39.343826	2024-02-20 18:52:39.343826	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-272	\N	Verma	Parent_Mother
87733562-5fd3-4c8e-a0bc-b9794fb68491	\N	Mishant	\N	\N	mishant@gmail.com	\N	0100636312	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-02-20 18:52:39.351459	2024-02-20 18:52:39.351459	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-273	\N	Verma	Parent_Guardian
87664c6d-911e-4713-8103-a6cba97127d3	\N	test	\N	\N	testf@gmail.com	\N	77777	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-03-22 00:22:55.962264	2024-03-22 00:22:55.962264	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-275	\N	father	Parent_Father
ceaa1311-46f2-4f9b-abf2-27412d2b728c	\N	test	\N	\N	testm@gmail.com	\N	77777	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-03-22 00:22:55.994276	2024-03-22 00:22:55.994276	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-276	\N	mother	Parent_Mother
8c5f3fb9-6dfc-4fe6-a84b-21b340abbdbe	\N	test	\N	\N	testg@gmail.com	\N	77777	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-03-22 00:22:56.001975	2024-03-22 00:22:56.001975	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-277	\N	guardian	Parent_Guardian
5aab6bab-c6d0-44ff-8ce2-2dfadb9bb0cf	\N	Sunil	\N	\N	\N	\N	567	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:05:38.199662	2024-04-02 00:05:38.199662	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-278	\N	Biswa	Parent_Father
dfb055c7-82ec-468c-a13c-794e34deebc8	\N	Mohani	\N	\N	\N	\N	567	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:05:38.218927	2024-04-02 00:05:38.218927	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-279	\N	Biswa	Parent_Mother
a6dc5af9-97f2-4b41-822b-fddcc9cfb766	\N	kalu	\N	\N	\N	\N	567	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:05:38.227033	2024-04-02 00:05:38.227033	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-280	\N	Biswa	Parent_Guardian
d3e9ee8d-72f7-4d27-95a0-bed83141d117	\N	Amit	\N	\N	\N	\N	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:23:49.586893	2024-04-02 00:23:49.586893	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-281	\N	Gupta	Parent_Father
0603bfa7-de33-4e73-996b-6e7bb8d8d632	\N	Mohani	\N	\N	\N	\N	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:23:49.608501	2024-04-02 00:23:49.608501	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-282	\N	Gupta	Parent_Mother
5bb154dd-365b-4041-922f-82ddf473bdb1	\N	LAlit	\N	\N	\N	\N	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:23:49.61607	2024-04-02 00:23:49.61607	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-283	\N	gupta	Parent_Guardian
821a4443-1397-4606-be70-73d33fb3b48e	\N	test	\N	\N	testuser97@yopmail.com	\N	1234	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:24:59.363165	2024-04-02 00:24:59.363165	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-284	\N	user	Parent_Father
4a98b31e-13d8-4310-af66-63ef23c2dad3	\N	Ramesh	\N	\N	\N	\N	1234	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:24:59.388604	2024-04-02 00:24:59.388604	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-285	\N	Jangir	Parent_Mother
b6da9859-67d5-46d1-9e53-b54ac93f4e67	\N	Prakash	\N	\N	\N	\N	1234	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-02 00:24:59.399475	2024-04-02 00:24:59.399475	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-286	\N	Jangir	Parent_Guardian
9db822b3-d3ff-4ead-8c44-9a9fb1f2e512	\N	test	\N	\N	testclass@yopmail.com	\N	5555	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-12 05:28:47.939345	2024-04-12 05:28:47.939345	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-287	\N	classname	Parent_Father
f2f23b0c-1f88-4ecf-a461-8c43143c0093	\N	Yashika	\N	\N	\N	\N	5555	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-12 05:28:47.968987	2024-04-12 05:28:47.968987	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-288	\N	Tripathi	Parent_Mother
08f73050-2532-4f79-914d-211a62c8419e	\N	test	\N	\N	\N	\N	5555	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-04-12 05:28:47.973846	2024-04-12 05:28:47.973846	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-289	\N	test	Parent_Guardian
e3f6ee50-bcd5-4e6e-921f-7c8a52f816e2	\N	test	\N	\N	testclass2001@yopmail.com	\N	5555	AWD	\N	\N	\N	\N	\N	\N	\N	ASDq	\N	\N	\N	2024-04-12 05:53:50.01592	2024-04-12 05:53:50.01592	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-290	\N	classname	Parent_Father
06b34e24-e6a5-467f-a13a-c80ac5111b50	\N	Mohani	\N	\N	testclasssw21@yopmail.com	\N	9876567678	ADS	\N	\N	\N	\N	\N	\N	\N	asd	\N	\N	\N	2024-04-12 05:53:50.0315	2024-04-12 05:53:50.0315	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-291	\N	ads	Parent_Mother
7e7b6454-2e7c-49e7-b3b1-de245c3a9cef	\N	sad	\N	\N	gameuse3001@yopmail.com	\N	909090771	ASD	\N	\N	\N	\N	\N	\N	\N	ED	\N	\N	\N	2024-04-12 05:53:50.035575	2024-04-12 05:53:50.035575	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-292	\N	user	Parent_Guardian
16cdab31-f0fa-4d1e-b54b-52cceadd8515	\N	ewfasfas	\N	\N	\N	\N	3412523455	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-10 18:54:47.648058	2024-05-10 18:54:47.648058	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-293	\N	fasfasdgs	Parent_Father
0814e232-1bb0-4d07-b4bb-9ed280ce77d6	\N	adsgfasd	\N	\N	\N	\N	4231456347	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-10 18:54:47.83516	2024-05-10 18:54:47.83516	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-294	\N	fasdgfasd	Parent_Mother
08d9a61c-460d-4efa-b0e3-2390c49c73ca	\N	gasdgas	\N	\N	\N	\N	4235434645	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-10 18:54:47.838345	2024-05-10 18:54:47.838345	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-295	\N	asdgasdfgvasd	Parent_Guardian
316f15f6-e3c2-4bdb-8b4c-6bdbd531eb9a	\N	kakusa	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:00:26.521692	2024-05-13 16:00:26.521692	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-296	\N	singh	Parent_Father
f8e342f9-823f-4dab-860a-07f81782469f	\N	kakisa	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:00:26.584576	2024-05-13 16:00:26.584576	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-297	\N	asf	Parent_Mother
840e8bb0-14f3-4367-84c0-934a21f51329	\N	qwertyu	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:00:26.587543	2024-05-13 16:00:26.587543	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-298	\N	efsardtfgyuhij	Parent_Guardian
58331130-6eaa-4ce3-97e1-3ac7f88898db	\N	kakusa	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:01:49.423849	2024-05-13 16:01:49.423849	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-299	\N	singh	Parent_Father
91c03780-59b1-4822-8c4e-44b79abf3857	\N	kakisa	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:01:49.47245	2024-05-13 16:01:49.47245	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-300	\N	asf	Parent_Mother
06f4df84-10c0-4332-9be9-158c3276f206	\N	qwertyu	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:01:49.477375	2024-05-13 16:01:49.477375	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-301	\N	efsardtfgyuhij	Parent_Guardian
44de4e06-8801-40b3-9d50-65942fa24021	\N	kakusa	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:09:48.448365	2024-05-13 16:09:48.448365	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-302	\N	singh	Parent_Father
6009127a-ad8d-48a7-a976-cea0863ea286	\N	kakisa	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:09:48.495455	2024-05-13 16:09:48.495455	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-303	\N	asf	Parent_Mother
79424874-8255-4d1d-8cca-3fbd3bde2b9c	\N	qwertyu	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2024-05-13 16:09:48.499743	2024-05-13 16:09:48.499743	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	CTC-304	\N	efsardtfgyuhij	Parent_Guardian
\.


                                                                                                                                                                                                                                                                                                                                                                                       4142.dat                                                                                            0000600 0004000 0002000 00000002363 14623575605 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        bb375024-7580-49d8-94a4-465427efc2b2	5c4f8422-d328-43af-b358-ec546579b694	1200	2023-07-25 00:00:00	2023-07-01	2023-07-30	\N	2023-07-25 10:47:28.119163	2023-07-25 10:47:28.119163	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	R-0016
5d58814e-2b85-43d4-b1e0-6727a1cc509f	e7d8e8c7-3267-46e4-81c0-65bbd6222c55	9000	2023-06-30 13:00:00	2023-06-29	2023-07-28	\N	2023-07-24 19:03:02.396571	2023-07-24 19:03:02.396571	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	R-0012
95836f68-af10-4293-b756-95a8a0fef673	e7d8e8c7-3267-46e4-81c0-65bbd6222c55	1200	2023-07-08 00:00:00	2023-07-01	2023-07-31	\N	2023-07-26 11:01:22.458641	2023-07-26 11:01:22.458641	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	R-0017
845370bc-5bb8-4741-b822-37aeaaabd6a2	291c7096-1f51-46d5-89ab-0c4b9873e20a	1200	2023-07-26 00:00:00	2023-07-01	2023-07-31	\N	2023-07-26 18:37:26.173152	2023-07-26 18:37:26.173152	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	R-0018
cdca4606-7370-4e40-8057-72af8b6ffade	e7d8e8c7-3267-46e4-81c0-65bbd6222c55	1200	\N	\N	\N	\N	2023-07-27 15:24:09.861209	2023-07-27 15:24:09.861209	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	R-0019
\.


                                                                                                                                                                                                                                                                             4143.dat                                                                                            0000600 0004000 0002000 00000001451 14623575605 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        73cf200b-0287-4826-bfde-f2dff78065d2	Army discount	5.00	c39ee366-9941-4fbd-92a2-13107e898003	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	2024-04-02 00:03:02.68176	2024-04-02 00:03:02.68176	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	Active
b1c4f488-4e49-4c33-a350-b36d2a77b5cd	Sibling discount	5.00	c39ee366-9941-4fbd-92a2-13107e898003	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	2024-04-02 00:03:22.36784	2024-04-02 00:03:22.36784	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	Active
6145d43a-87e5-4bce-ba8a-b957352b916d	Sports discount	15.00	c39ee366-9941-4fbd-92a2-13107e898003	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	2024-04-02 00:03:50.31501	2024-04-02 00:03:50.31501	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	Active
\.


                                                                                                                                                                                                                       4144.dat                                                                                            0000600 0004000 0002000 00000001060 14623575605 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        79afb979-20d0-4257-beaf-1b480d14c8a7	ffffb0ad-dc4a-458b-9802-526451bb41e1	73cf200b-0287-4826-bfde-f2dff78065d2
13965ebb-872b-4c7a-8178-4150f74c7bd3	ffffb0ad-dc4a-458b-9802-526451bb41e1	b1c4f488-4e49-4c33-a350-b36d2a77b5cd
c91819b6-e015-4085-81a3-36a053e19f92	86d618d6-682d-4168-8e78-60c5fc9265a6	73cf200b-0287-4826-bfde-f2dff78065d2
7fc0d689-ebdb-40fb-9054-c88530644adb	86d618d6-682d-4168-8e78-60c5fc9265a6	b1c4f488-4e49-4c33-a350-b36d2a77b5cd
790fd335-d3cd-455f-897f-8ac7040d6aee	5f009d88-43ec-4209-abe8-f932510ea377	b1c4f488-4e49-4c33-a350-b36d2a77b5cd
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                4145.dat                                                                                            0000600 0004000 0002000 00000002515 14623575605 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        54aacffb-cabd-43af-a181-bc2d11154a63	Holiday	2023-10-13	20:17:00	2023-10-17	22:17:00		Holi	#db3e00	2023-10-12 18:17:46.419744	2023-10-12 18:17:46.419744	\N	\N	\N	\N
99a06bd3-ff44-477b-a109-fe312fd86fa4	Festiwal	2023-10-17	00:00:00	2023-10-17	12:00:00		Navratri	#cf16f0	2023-10-16 18:49:58.191294	2023-10-16 18:49:58.191294	\N	\N	\N	\N
53ac71dc-ec3e-4403-b95a-1cb13cf92dc4	Festiwal	2023-11-10	18:14:00	2023-11-15	21:15:00		Bhai Dooj1	#db3e00	2023-10-12 18:15:13.696297	2023-10-12 18:15:13.696297	\N	\N	\N	\N
cb24e061-5461-42fe-9fbb-83dc86e79196	Festival	2023-10-27	13:05:00	2023-10-27	14:05:00		Makar Skranti	#b52aed	2023-10-26 11:05:47.333176	2023-10-26 11:05:47.333176	\N	\N	\N	\N
2785dded-af9d-4a23-b6d2-2ac0fa1ff438	Festiwal	2023-11-11	17:52:00	2023-11-12	19:57:00		Diwali	#b80000	2023-11-06 17:53:12.700931	2023-11-06 17:53:12.700931	\N	\N	\N	\N
d1e0036c-fc0b-4758-8c29-ab9d70ee499e	National Day	2024-01-26	00:00:00	2024-01-26	12:00:00		Republic Day		2024-01-12 16:12:20.223381	2024-01-12 16:12:20.223381	\N	\N	\N	\N
5a112bc7-d6c5-4fdc-bfa9-d17142be8eeb	National Day	2024-01-26	20:36:00	2024-01-26	22:36:00		26 jan		2024-01-18 16:36:13.024657	2024-01-18 16:36:13.024657	\N	\N	\N	\N
16243c7f-10ed-4265-8d53-5e8e2f54d4d7	Festival	2024-01-30	18:39:00	2024-01-31	21:39:00		Holi	#db3e00	2024-01-18 16:40:00.115124	2024-01-18 16:40:00.115124	\N	\N	\N	\N
\.


                                                                                                                                                                                   4146.dat                                                                                            0000600 0004000 0002000 00000002553 14623575605 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        00e89f39-106e-4f4b-bf10-bb4a2cb6fd29	102a54eb-82e1-4fa1-84bd-89c3bb56b579	2023-11-30	16:30:00	17:30:00	1	303	f66055ec-634e-4085-9d25-7ab0d704b083	Upcoming	7cd16451-290f-4fca-b90b-c8a6973f9e6c	10c22f00-1f9b-4946-aed4-4f75e82cf36d	100	40	f	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
5af90be6-74c7-4a74-9728-eaaf53422d08	5c5a98fb-699b-49c9-8d7d-df472b9e640d	2024-02-10	09:19:00	10:27:00	68	room-121	1b75aa46-6b27-494a-a846-7e19215ebd24	Upcoming	e06efc22-b276-45da-8de0-af656c859697	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	100	40	t	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
82c93ebe-7ac4-4c4b-b278-66ae64995fa8	231be48e-12bc-41cb-9402-7c54be8ec86e	2023-11-07	17:48:00	19:48:00	2	201	e8e8c15b-d86e-4e75-8674-86ddf95d02c9	Upcoming	e06efc22-b276-45da-8de0-af656c859697	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	100	40	\N	c39ee366-9941-4fbd-92a2-13107e898003
96ca0cb4-2fd5-4575-a2c9-989b0b19dd19	aca9f567-c571-4166-b490-b66ca396ac88	2023-10-28	10:00:00	11:30:00	1	301	742fbd1c-32b7-462e-b73b-dde1c04f588f	Upcoming	08124c21-c903-4c05-a864-26611bb2cc7c	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	100	40	f	c39ee366-9941-4fbd-92a2-13107e898003
bfda82b0-1641-4bc9-b39f-fb8b3e9743d6	055303a4-1f68-4d27-8faa-9f98e8c0f881	2023-10-29	08:00:00	11:00:00	3	202	fcf9308d-c914-4469-a3f3-0734a49e0fce	Upcoming	e06efc22-b276-45da-8de0-af656c859697	61724501-a791-40f4-8ab9-ad908af677b9	100	36	f	c39ee366-9941-4fbd-92a2-13107e898003
\.


                                                                                                                                                     4147.dat                                                                                            0000600 0004000 0002000 00000001004 14623575605 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        231be48e-12bc-41cb-9402-7c54be8ec86e	Final	Active	\N
102a54eb-82e1-4fa1-84bd-89c3bb56b579	Final Exam12	InActive	\N
055303a4-1f68-4d27-8faa-9f98e8c0f881	Unit-Test13	Active	\N
727acb0b-0468-4a41-bbef-7462add96aed	Mid-Term14	Active	\N
5c5a98fb-699b-49c9-8d7d-df472b9e640d	First-Term	Active	c39ee366-9941-4fbd-92a2-13107e898003
aca9f567-c571-4166-b490-b66ca396ac88	Unit-Test1	Active	c39ee366-9941-4fbd-92a2-13107e898003
38249c51-21ea-4e5c-969b-f1a8dba6988c	Unit-Test12	InActive	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            4148.dat                                                                                            0000600 0004000 0002000 00000000333 14623575605 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        39bf8319-9d71-4a07-b4b7-39c0991d7c65	500	3	4	Active
2814e65b-5153-4c39-887f-393265faf595	1500	7	8	Active
a57133a5-7f69-4b17-a58d-fccef56e53e1	700	5	6	Active
b08ce499-be1f-443a-a782-7b6519fa39b3	2000	11	15	Inactive
\.


                                                                                                                                                                                                                                                                                                     4149.dat                                                                                            0000600 0004000 0002000 00000000005 14623575605 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4151.dat                                                                                            0000600 0004000 0002000 00000003153 14623575605 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        a3859c8a-fdae-4084-bb9d-6abde3fe40e9	Tution Fee	2023-11-28 15:29:18.928643	2023-11-28 15:29:18.928643	\N	\N	Active	\N
edaa80ab-8cf9-4b20-8068-0057d1df31b0	Sports Fee	2023-11-28 15:30:12.716717	2023-11-28 15:30:12.716717	\N	\N	Active	\N
b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	Registration Fee	2023-11-28 15:30:12.716717	2023-11-28 15:30:12.716717	\N	\N	Active	\N
51f60520-46ec-4c29-9d13-fe37cad94d60	Medical Fee	2024-01-18 16:32:07.484131	2024-01-18 16:32:07.484131	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	\N
359fd72b-4e95-4bd2-b079-92aaa98f54b5	Library Fee	2024-01-23 18:37:07.605214	2024-01-23 18:37:07.605214	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	\N
153a69ad-6386-4d26-b6db-68b5c5e47d24	test	2024-01-23 18:41:19.579345	2024-01-23 18:41:19.579345	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	\N
2bdc583b-cee6-4ccd-9ae0-e62938458b19	test1	2024-01-23 18:49:34.625044	2024-01-23 18:49:34.625044	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	\N
1b684ac4-1a93-4282-a722-1e78c6909c8d	test2	2024-01-23 18:50:39.8018	2024-01-23 18:50:39.8018	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	\N
39727be7-8c1a-45ef-bf3f-1e31b472b64b	Mi	2024-01-24 16:49:44.031123	2024-01-24 16:49:44.031123	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	\N
b63970c1-5e71-43b1-bf16-fa34d29e662a	Test April	2024-04-02 00:06:27.225203	2024-04-02 00:06:27.225203	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	InActive	\N
\.


                                                                                                                                                                                                                                                                                                                                                                                                                     4152.dat                                                                                            0000600 0004000 0002000 00000045607 14623575605 0014276 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        6a93c39a-2502-44f8-b05b-695975db1363	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	100	100	100	100	2024-04-02 00:25:37.680435	2024-04-02 00:25:37.680435	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	77a2b139-5430-476c-9c98-d3631458b032
a0f97cea-7dd2-4dcb-bf3b-25fcd9295a3f	edaa80ab-8cf9-4b20-8068-0057d1df31b0	200	200	200	200	2024-04-02 00:25:37.683545	2024-04-02 00:25:37.683545	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	77a2b139-5430-476c-9c98-d3631458b032
eaafcf38-48f8-4a4c-928b-9de03db9591f	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	100	100	100	100	2024-04-02 00:25:37.700457	2024-04-02 00:25:37.700457	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	ddfc2b86-9b8e-40eb-bd8c-cf4c2c26c83b
666fbce0-cf21-4e08-8bfe-d914e6d5e659	edaa80ab-8cf9-4b20-8068-0057d1df31b0	200	200	200	200	2024-04-02 00:25:37.702578	2024-04-02 00:25:37.702578	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	ddfc2b86-9b8e-40eb-bd8c-cf4c2c26c83b
3525838a-c319-4cfb-a9d9-1d5a2f319de0	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	100	100	100	100	2024-04-02 00:25:37.704149	2024-04-02 00:25:37.704149	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	5ec0a1a5-cfa9-4de0-8fd7-2ff19928b043
f204d981-77cd-41f9-ab9b-e981c39ff28a	edaa80ab-8cf9-4b20-8068-0057d1df31b0	200	200	200	200	2024-04-02 00:25:37.705433	2024-04-02 00:25:37.705433	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	5ec0a1a5-cfa9-4de0-8fd7-2ff19928b043
785a381c-2158-4e62-8798-d1bdc9a046ea	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-04-02 00:26:28.254138	2024-04-02 00:26:28.254138	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	8465569b-31b3-41d9-b0f8-eafde8964dfc
12f88b19-65bb-4f6a-83d2-aa68e2274da1	edaa80ab-8cf9-4b20-8068-0057d1df31b0	300	300	300	300	2024-04-02 00:26:28.262683	2024-04-02 00:26:28.262683	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	8465569b-31b3-41d9-b0f8-eafde8964dfc
a23fc5b9-c93c-43a3-a98e-23c3b5c81384	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	100	100	100	100	2024-04-02 00:26:28.273611	2024-04-02 00:26:28.273611	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	8465569b-31b3-41d9-b0f8-eafde8964dfc
a2500e05-79ad-4ee1-968a-b19392693b60	51f60520-46ec-4c29-9d13-fe37cad94d60	100	100	100	100	2024-04-02 00:26:28.27953	2024-04-02 00:26:28.27953	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	8465569b-31b3-41d9-b0f8-eafde8964dfc
163f4e17-bde5-494a-8b7d-d062806c2ff7	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-04-02 00:26:28.281867	2024-04-02 00:26:28.281867	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	e770ab27-e6b9-46ab-a6e5-662855506eb1
c3510e42-67c8-4b06-ac29-2da591e765e5	edaa80ab-8cf9-4b20-8068-0057d1df31b0	300	300	300	300	2024-04-02 00:26:28.283249	2024-04-02 00:26:28.283249	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	e770ab27-e6b9-46ab-a6e5-662855506eb1
6271d541-066d-44ac-a2e5-2e77992e8ceb	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	100	100	100	100	2024-04-02 00:26:28.308017	2024-04-02 00:26:28.308017	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	e770ab27-e6b9-46ab-a6e5-662855506eb1
ad727515-b834-4f54-93e0-c274c841a5f2	51f60520-46ec-4c29-9d13-fe37cad94d60	100	100	100	100	2024-04-02 00:26:28.310991	2024-04-02 00:26:28.310991	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	e770ab27-e6b9-46ab-a6e5-662855506eb1
0877dd54-5871-4332-b720-cd75197e4c58	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-04-02 00:26:28.312834	2024-04-02 00:26:28.312834	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	356fe925-f5be-4e05-b20b-c4cbb75eebc3
3c10cd52-d831-432e-b2ce-77b5c97c9433	edaa80ab-8cf9-4b20-8068-0057d1df31b0	300	300	300	300	2024-04-02 00:26:28.314183	2024-04-02 00:26:28.314183	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	356fe925-f5be-4e05-b20b-c4cbb75eebc3
38737414-115a-45fd-b36c-b28ccd6c10ec	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	100	100	100	100	2024-04-02 00:26:28.315911	2024-04-02 00:26:28.315911	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	356fe925-f5be-4e05-b20b-c4cbb75eebc3
e18bc56a-439c-4654-bf01-a065ff9444ad	51f60520-46ec-4c29-9d13-fe37cad94d60	100	100	100	100	2024-04-02 00:26:28.326314	2024-04-02 00:26:28.326314	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	356fe925-f5be-4e05-b20b-c4cbb75eebc3
534d3375-e65a-4d9c-9d41-f58d7136c592	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-04-02 00:26:28.328303	2024-04-02 00:26:28.328303	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	d5283ee9-d96a-417c-b2eb-2c2ed0d9016d
d2fff911-d1a3-45db-a262-8feb7146907b	edaa80ab-8cf9-4b20-8068-0057d1df31b0	300	300	300	300	2024-04-02 00:26:28.329687	2024-04-02 00:26:28.329687	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	d5283ee9-d96a-417c-b2eb-2c2ed0d9016d
092e8892-4f24-479b-84e6-52f38f037a77	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	100	100	100	100	2024-04-02 00:26:28.331122	2024-04-02 00:26:28.331122	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	d5283ee9-d96a-417c-b2eb-2c2ed0d9016d
ab3740e7-5d44-43eb-b09a-9b7bb1e42860	51f60520-46ec-4c29-9d13-fe37cad94d60	100	100	100	100	2024-04-02 00:26:28.332386	2024-04-02 00:26:28.332386	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	d5283ee9-d96a-417c-b2eb-2c2ed0d9016d
13ce1d8f-0cb0-492b-a867-dc54534c304a	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-04-02 00:26:28.333591	2024-04-02 00:26:28.333591	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	1a66a38d-8f8e-4419-ae7c-1da70f288951
9414dade-ee05-4d0e-ad6e-92ebea66d683	edaa80ab-8cf9-4b20-8068-0057d1df31b0	300	300	300	300	2024-04-02 00:26:28.337586	2024-04-02 00:26:28.337586	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	1a66a38d-8f8e-4419-ae7c-1da70f288951
cce1dc65-718d-4e74-a2d0-7f77b5d53bd0	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	100	100	100	100	2024-04-02 00:26:28.339649	2024-04-02 00:26:28.339649	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	1a66a38d-8f8e-4419-ae7c-1da70f288951
42706b34-9ddf-45af-9a5c-60237dc8f51b	51f60520-46ec-4c29-9d13-fe37cad94d60	100	100	100	100	2024-04-02 00:26:28.340992	2024-04-02 00:26:28.340992	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	1a66a38d-8f8e-4419-ae7c-1da70f288951
d0ae1fac-baeb-4872-b728-f0308a7f91e1	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-04-02 00:26:28.342345	2024-04-02 00:26:28.342345	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	f9d0feb7-30d5-4322-94d9-fb73803422e6
fd907316-f70e-4df8-8e65-de6efa6f6cc5	edaa80ab-8cf9-4b20-8068-0057d1df31b0	300	300	300	300	2024-04-02 00:26:28.344187	2024-04-02 00:26:28.344187	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	f9d0feb7-30d5-4322-94d9-fb73803422e6
8736284b-9fb3-42b0-aaf1-11df6c4b8004	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	100	100	100	100	2024-04-02 00:26:28.346037	2024-04-02 00:26:28.346037	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	f9d0feb7-30d5-4322-94d9-fb73803422e6
753b1438-ffc1-4422-aa8b-5b4318b27fc3	51f60520-46ec-4c29-9d13-fe37cad94d60	100	100	100	100	2024-04-02 00:26:28.347501	2024-04-02 00:26:28.347501	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	f9d0feb7-30d5-4322-94d9-fb73803422e6
44623529-46de-46d8-8fea-0f4758ecf7ad	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:11.926652	2024-05-10 17:54:11.926652	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	f0706067-583b-4900-971c-5719ff4d2d66
aa67ee78-ff88-416a-92f5-ae17c4d25872	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:11.940687	2024-05-10 17:54:11.940687	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	f0706067-583b-4900-971c-5719ff4d2d66
67e4cc9d-d035-4c3f-90e1-2f7f88b87513	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:11.95924	2024-05-10 17:54:11.95924	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	f0706067-583b-4900-971c-5719ff4d2d66
e3a47aa8-55fe-4e1c-a79b-c5772e2cdc8e	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:11.962396	2024-05-10 17:54:11.962396	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	58a7273f-c130-44b4-8d1b-df4e52c0c1b5
f50f05ce-260d-4729-ae80-5243996b07a3	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:11.966495	2024-05-10 17:54:11.966495	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	58a7273f-c130-44b4-8d1b-df4e52c0c1b5
9bf3253e-83bd-4033-b714-fdb84e55d903	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:11.969462	2024-05-10 17:54:11.969462	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	58a7273f-c130-44b4-8d1b-df4e52c0c1b5
83e25379-618f-427d-a1d0-b6342a039553	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:11.972071	2024-05-10 17:54:11.972071	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	64a531cf-685f-497a-a87c-ea8ebe9b0cee
a021c439-dd91-415f-8415-f394ea6cabd8	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:11.974779	2024-05-10 17:54:11.974779	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	64a531cf-685f-497a-a87c-ea8ebe9b0cee
054d7b07-5749-4391-bb28-0374c3d39c2d	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:11.977616	2024-05-10 17:54:11.977616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	64a531cf-685f-497a-a87c-ea8ebe9b0cee
3837066c-aae2-4588-a023-7c9ea6aa97e3	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:11.98342	2024-05-10 17:54:11.98342	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	cebf6d56-f511-46e3-ab4b-1512fb345918
a2b69b99-ef23-4a3e-a391-8c335771c8d5	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:11.986281	2024-05-10 17:54:11.986281	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	cebf6d56-f511-46e3-ab4b-1512fb345918
c1908d60-8652-4d21-918b-60e6820e8918	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:11.988853	2024-05-10 17:54:11.988853	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	cebf6d56-f511-46e3-ab4b-1512fb345918
1202337b-3dd0-4f4f-b7b0-d93a0e234d41	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:11.991804	2024-05-10 17:54:11.991804	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	e4e2343d-9e3e-480e-bced-19400b7675f1
a19a18b4-ffe2-4d6e-8e51-f2de288073cc	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:11.994622	2024-05-10 17:54:11.994622	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	e4e2343d-9e3e-480e-bced-19400b7675f1
2d3b19ae-ae42-4d0a-a0f0-5613923d3ecd	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.001563	2024-05-10 17:54:12.001563	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	e4e2343d-9e3e-480e-bced-19400b7675f1
caab0b6b-4371-4304-9b33-a49cd6ab0269	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.004258	2024-05-10 17:54:12.004258	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	a740325d-5d41-4f03-ab0e-e44099e97339
618d7126-1b53-40f7-9720-c443b3ac7aae	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.006981	2024-05-10 17:54:12.006981	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	a740325d-5d41-4f03-ab0e-e44099e97339
95145035-b995-44c9-9e4c-c063fa5aeed1	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.010075	2024-05-10 17:54:12.010075	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	a740325d-5d41-4f03-ab0e-e44099e97339
aa4022e0-8749-4363-9d81-2a016d6e1f13	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.01297	2024-05-10 17:54:12.01297	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	6bdab40e-3d86-43d1-bd69-7434600dcc81
6a0ca386-ca95-4a69-adb6-36628c14e666	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.015685	2024-05-10 17:54:12.015685	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	6bdab40e-3d86-43d1-bd69-7434600dcc81
a93c1077-095c-41ac-be94-f637b176ec35	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.01992	2024-05-10 17:54:12.01992	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	6bdab40e-3d86-43d1-bd69-7434600dcc81
89316013-1eb2-4e30-bebc-a03f6069dc0a	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.0229	2024-05-10 17:54:12.0229	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	99055d9b-6c93-434f-9087-47b6145e6a60
d3cc9136-e36f-4bff-a4b8-e9604b612fa0	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.025998	2024-05-10 17:54:12.025998	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	99055d9b-6c93-434f-9087-47b6145e6a60
dfd9c2ac-0991-488d-b7a9-726da7842755	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.029714	2024-05-10 17:54:12.029714	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	99055d9b-6c93-434f-9087-47b6145e6a60
1113004a-4105-4cc7-ba4c-a7ffeb82b3fc	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.033493	2024-05-10 17:54:12.033493	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	e8dc191f-3327-4e0d-ab63-eb6629bad3ae
6fcc96f7-b921-4569-9bf0-b048b24076ec	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.039435	2024-05-10 17:54:12.039435	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	e8dc191f-3327-4e0d-ab63-eb6629bad3ae
58da093a-619b-445d-b14e-07c2b57c41de	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.042707	2024-05-10 17:54:12.042707	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	e8dc191f-3327-4e0d-ab63-eb6629bad3ae
2689fbbd-6f42-4d21-ac0a-71370ac6c49d	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.046614	2024-05-10 17:54:12.046614	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	b66828c3-6b2a-4170-8301-542a67221c00
fe73abec-a735-4e0f-aec0-4b601a951ed2	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.049395	2024-05-10 17:54:12.049395	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	b66828c3-6b2a-4170-8301-542a67221c00
97fdaa01-8d2e-4353-842d-e74b07428d57	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.057548	2024-05-10 17:54:12.057548	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	b66828c3-6b2a-4170-8301-542a67221c00
36ced95d-55f4-48a1-b21c-ca6e121614a9	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.060557	2024-05-10 17:54:12.060557	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	9707edbd-8b65-444b-85df-8ed235b48921
819727b3-35ff-4cc2-bb93-c31109b34668	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.063942	2024-05-10 17:54:12.063942	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	9707edbd-8b65-444b-85df-8ed235b48921
17f025fc-dc07-4f98-970d-d6d690133157	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.067947	2024-05-10 17:54:12.067947	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	9707edbd-8b65-444b-85df-8ed235b48921
be38505d-5178-4ef6-9444-b9b2b351d4e2	a3859c8a-fdae-4084-bb9d-6abde3fe40e9	1000	1000	1000	1000	2024-05-10 17:54:12.074008	2024-05-10 17:54:12.074008	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	64745286-1c6e-4147-918b-d309d1e8761d
6fc56e67-2253-4b96-a08a-c639e4215389	b54ee1e6-9d0a-4494-9ef5-13164ecf38a6	500	500	500	500	2024-05-10 17:54:12.078622	2024-05-10 17:54:12.078622	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	64745286-1c6e-4147-918b-d309d1e8761d
e0f84cd1-9140-4033-a462-c2e33b34292a	edaa80ab-8cf9-4b20-8068-0057d1df31b0	250	250	250	250	2024-05-10 17:54:12.083119	2024-05-10 17:54:12.083119	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	3fe255ed-1633-4b21-af0a-f607638f0ae4	64745286-1c6e-4147-918b-d309d1e8761d
\.


                                                                                                                         4153.dat                                                                                            0000600 0004000 0002000 00000001510 14623575605 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        0323aad4-7e7f-4ac4-bda9-1cda89bd6472	Active	61724501-a791-40f4-8ab9-ad908af677b9	2024-04-02 00:25:37.609091	2024-04-02 00:25:37.609091	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Monthly	New	c39ee366-9941-4fbd-92a2-13107e898003	900	900	900	900
9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	Active	91aa892b-28e9-4bb7-a466-6c816bc6d429	2024-04-02 00:26:28.165536	2024-04-02 00:26:28.165536	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Bi-Monthly	New	c39ee366-9941-4fbd-92a2-13107e898003	9000	9000	9000	9000
3fe255ed-1633-4b21-af0a-f607638f0ae4	Active	91aa892b-28e9-4bb7-a466-6c816bc6d429	2024-05-10 17:54:11.83276	2024-05-10 17:54:11.83276	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Monthly	New	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	21000	21000	21000	21000
\.


                                                                                                                                                                                        4154.dat                                                                                            0000600 0004000 0002000 00000012141 14623575605 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        77a2b139-5430-476c-9c98-d3631458b032	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:55:37.652	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	April	300	300	300	300
ddfc2b86-9b8e-40eb-bd8c-cf4c2c26c83b	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:55:37.652	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	May	300	300	300	300
5ec0a1a5-cfa9-4de0-8fd7-2ff19928b043	0323aad4-7e7f-4ac4-bda9-1cda89bd6472	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:55:37.652	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	June	300	300	300	300
8465569b-31b3-41d9-b0f8-eafde8964dfc	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:56:28.212	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	April to May	1500	1500	1500	1500
e770ab27-e6b9-46ab-a6e5-662855506eb1	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:56:28.212	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	June to July	1500	1500	1500	1500
356fe925-f5be-4e05-b20b-c4cbb75eebc3	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:56:28.212	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	August to September	1500	1500	1500	1500
d5283ee9-d96a-417c-b2eb-2c2ed0d9016d	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:56:28.212	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	October to November	1500	1500	1500	1500
1a66a38d-8f8e-4419-ae7c-1da70f288951	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:56:28.212	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	December to January	1500	1500	1500	1500
f9d0feb7-30d5-4322-94d9-fb73803422e6	9ff2e433-1e6e-486e-8ad2-67ffaa8f4adc	c39ee366-9941-4fbd-92a2-13107e898003	\N	2024-04-02 12:56:28.212	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	February to March	1500	1500	1500	1500
f0706067-583b-4900-971c-5719ff4d2d66	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	April	1750	1750	1750	1750
58a7273f-c130-44b4-8d1b-df4e52c0c1b5	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	May	1750	1750	1750	1750
64a531cf-685f-497a-a87c-ea8ebe9b0cee	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	June	1750	1750	1750	1750
cebf6d56-f511-46e3-ab4b-1512fb345918	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	July	1750	1750	1750	1750
e4e2343d-9e3e-480e-bced-19400b7675f1	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	August	1750	1750	1750	1750
a740325d-5d41-4f03-ab0e-e44099e97339	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	September	1750	1750	1750	1750
6bdab40e-3d86-43d1-bd69-7434600dcc81	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	October	1750	1750	1750	1750
99055d9b-6c93-434f-9087-47b6145e6a60	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	November	1750	1750	1750	1750
e8dc191f-3327-4e0d-ab63-eb6629bad3ae	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	December	1750	1750	1750	1750
b66828c3-6b2a-4170-8301-542a67221c00	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	January	1750	1750	1750	1750
9707edbd-8b65-444b-85df-8ed235b48921	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	February	1750	1750	1750	1750
64745286-1c6e-4147-918b-d309d1e8761d	3fe255ed-1633-4b21-af0a-f607638f0ae4	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	\N	2024-05-10 17:54:11.873	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Active	March	1750	1750	1750	1750
\.


                                                                                                                                                                                                                                                                                                                                                                                                                               4155.dat                                                                                            0000600 0004000 0002000 00000002232 14623575605 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        dc357fd0-6211-484f-9f69-8ac5ff56d3ae	NajmunSakibPhoto.jfif	jpeg, jpg	7786	2023-07-21 12:56:55.574118	cd1ebbed-e3c5-4da8-8eff-4369112571f3		84f3b53a-a3d6-448d-904f-53d6593478a6	2023-07-21 12:56:55.574118	cd1ebbed-e3c5-4da8-8eff-4369112571f3
5d045efc-4f0c-4038-8021-cca232e0dff6	NajmunSakibPhoto.jfif	jpeg, jpg	191	2023-07-24 10:22:28.189727	cd1ebbed-e3c5-4da8-8eff-4369112571f3		e7d8e8c7-3267-46e4-81c0-65bbd6222c55	2023-07-24 10:22:28.189727	cd1ebbed-e3c5-4da8-8eff-4369112571f3
3e36276c-13f9-4085-8950-a26d6dfff004	UPHC List (1).xlsx	xlsx	115104	2023-07-24 18:23:06.499312	cd1ebbed-e3c5-4da8-8eff-4369112571f3		e7d8e8c7-3267-46e4-81c0-65bbd6222c55	2023-07-24 18:23:06.499312	cd1ebbed-e3c5-4da8-8eff-4369112571f3
2640291a-72fb-481c-9170-a20da8429c9a	DashBoard.xlsx	xlsx	20334	2023-07-26 11:32:36.757827	cd1ebbed-e3c5-4da8-8eff-4369112571f3		054be25c-1674-4188-85e7-072e1aab4551	2023-07-26 11:32:36.757827	cd1ebbed-e3c5-4da8-8eff-4369112571f3
63a1539d-fd64-4c46-91c8-2b367e939ea1	DashBoard (2).xlsx	xlsx	191	2023-07-26 18:56:51.725869	cd1ebbed-e3c5-4da8-8eff-4369112571f3		5cc58cad-ee0c-476a-b763-f516344e2672	2023-07-26 18:56:51.725869	cd1ebbed-e3c5-4da8-8eff-4369112571f3
\.


                                                                                                                                                                                                                                                                                                                                                                      4156.dat                                                                                            0000600 0004000 0002000 00000000271 14623575605 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1fbc123f-8d30-429c-b090-1f2c0067ac77	D	40	59
83d251bc-bb97-4f86-8190-311d379cf63f	C	60	79
87eb2d6e-525c-45c8-b6d1-a12b1896a592	A	80	100
7c30b848-233a-4b3b-9126-84ff79078158	B	0	39
\.


                                                                                                                                                                                                                                                                                                                                       4158.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4159.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4160.dat                                                                                            0000600 0004000 0002000 00000002736 14623575606 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        da8c3be7-5af2-4cbf-9895-81db3af1864c	Shikha	varma	\N	\N	\N	shikha@gmail.com	\N	1111	\N	\N	\N	\N	\N	\N	2024-05-10 15:53:58.886352	2024-04-12 01:04:20.261276	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Dr. Prakash	Sharma	\N	\N	\N	\N	Not Registered	60795019-968d-409a-80c6-0e5705f6a51f
650d2e01-07cd-402e-a914-77c2ac1d8a11	test	classname	\N	\N	\N	testclass@yopmail.com	\N	5555	\N	\N	\N	\N	\N	\N	2024-05-10 15:55:33.816693	2024-04-12 03:44:39.100744	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	test	class father	\N	\N	\N	\N	Registered	\N
143b1517-a8ce-46d6-bb64-0eefc47d55cb	test	classname	\N	\N	\N	testclass@yopmail.com	\N	5555	\N	\N	\N	\N	\N	\N	2024-05-10 15:55:33.816693	2024-04-12 03:46:16.856633	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	test	class father	\N	\N	\N	\N	Registered	\N
224ea596-b3f1-4079-8b34-16e3bac72fed	test	classname	\N	\N	\N	testclass@yopmail.com	\N	5555	\N	\N	\N	\N	\N	\N	2024-05-10 15:55:33.816693	2024-04-12 03:47:05.664472	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	test	class father	\N	\N	\N	\N	Not Registered	\N
2d1d03c2-0294-433e-9a44-485e6df8ab11	test	classname	\N	\N	Male	testclass@yopmail.com		5555	456001	India	Ujjain	Madhya Pradesh	\N	\N	2024-05-10 15:57:12.619543	2024-04-12 03:46:41.71003	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	test	class father	\N	\N	\N	\N	Registered	91aa892b-28e9-4bb7-a466-6c816bc6d429
\.


                                  4161.dat                                                                                            0000600 0004000 0002000 00000020301 14623575606 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        56761bf4-ffe2-4405-a556-947488183110	07fbd8f4-ca8f-4def-83fd-a6be4174e034	2023-07-21 00:00:00	2023-07-29 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
3de70e7f-23d4-46cc-87eb-3488677d5009	df37d24c-827e-41bd-a2a0-c6937b545db5	2023-07-16 00:00:00	2023-07-23 00:00:00			2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
5d6d9b17-8d29-4050-b770-93554a745ff6	7cec2720-593c-4456-9262-041cb228be90	2023-07-07 00:00:00	2023-07-19 00:00:00	Full Day	w	2023-07-17 22:46:25.777916	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
8a2c2037-e99b-4080-aceb-0e82ba847733	f7cc0903-a529-4470-9b7d-e4c8f41c0249	2023-07-23 00:00:00	2023-07-12 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
c4d3d0ab-13e8-401c-9d0c-bf98a1f5ee9a	b2f100e5-347e-4fa6-be89-6b0b507b4128	2023-07-20 00:00:00	2023-07-06 00:00:00	Full Day	Sick Leave	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
188d36a9-5e28-476f-96e0-0f1ac4a67f4c	18640b2b-bdda-4879-a3b8-ab62d78eee83	2023-07-19 18:30:00	2023-07-19 18:30:00	Half Day	Call From his home	2023-07-26 16:23:08.317634	2023-06-22 12:34:25.933	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
4bcddadc-7bb4-4902-8fb2-b8820064f0de	49e6139d-8d3e-42bd-b7ff-20b62a0ba0e5	2023-07-20 00:00:00	2023-07-24 00:00:00	Full Day	Medical Leave	2023-07-20 08:22:03.657352	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
dd1b31bd-b773-4a9d-99d1-e581f6d2ec4f	\N	2023-07-06 00:00:00	2023-07-08 00:00:00	Full Day		2023-07-20 08:22:03.657352	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
a21ab033-8267-4595-a72d-d187e84acb60	\N	2023-07-15 00:00:00	2023-07-16 00:00:00	Half Day	Viral Fever	2023-07-20 08:22:03.657352	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
2b4c1d2e-a462-40dd-8c78-a2fb6ce4d05c	\N	2023-07-25 00:00:00	2023-07-26 00:00:00	Full Day	Sick Leave	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
99ff2ca7-4aaf-4e8c-8e9b-9627b71d4f2f	\N	2023-07-25 00:00:00	2023-07-26 00:00:00	Full Day	Sick Leave	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
d6c21f2c-b217-49d3-a758-07e5ccd0069e	\N	2023-07-25 00:00:00	2023-07-26 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
bdcf435a-62a3-4d01-8edd-3194636ce3d9	\N	2023-07-25 00:00:00	2023-07-26 00:00:00	Full Day	Regarding Sick Leave	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
1fed12cf-ec01-4e10-a856-32bd23c69438	e7d8e8c7-3267-46e4-81c0-65bbd6222c55	2023-07-19 00:00:00	2023-07-06 00:00:00	Full Day	Regarding Sick Leave	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
28640ed5-9841-4bc9-a6e8-75f07c5ee0c1	5cc58cad-ee0c-476a-b763-f516344e2672	2023-06-29 00:00:00	2023-08-05 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
e051eb65-3fc0-49df-a8d9-25de999103cf	5cc58cad-ee0c-476a-b763-f516344e2672	2023-06-28 00:00:00	2023-07-13 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
dc1bf6a2-1b8f-4f70-a75d-88890a5c1c7d	5cc58cad-ee0c-476a-b763-f516344e2672	2023-07-12 00:00:00	2023-07-13 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
e7c794ff-d92e-4de2-af64-a95d66929371	a2f89613-aeba-4b30-90bd-8f7f0aba9863	2023-07-07 00:00:00	2023-07-08 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
67f5e347-81ca-444a-bf77-392982a3cfb6	a2f89613-aeba-4b30-90bd-8f7f0aba9863	2023-07-29 00:00:00	2023-07-29 00:00:00	Half Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
a37981d1-d0d3-4291-8448-d013f7cc9918	\N	2023-07-07 00:00:00	2023-07-19 00:00:00	Full Day	w	2023-08-09 18:52:40.543061	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
4c829368-877a-4d97-a66f-8db1f3355a33	47888890-cfd0-4060-80d6-a13b1e57d361	2023-07-23 00:00:00	2023-07-23 00:00:00	Half Day		2023-08-09 18:56:27.562392	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
81e4a8ba-3416-40a4-8385-1daf0b92d4bd	47888890-cfd0-4060-80d6-a13b1e57d361	2023-08-09 00:00:00	2023-08-11 00:00:00	Full Day	Nhi aa rha	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
7136eaf8-c92b-483e-803d-87335376e6bb	40ec3ce9-19e9-49b6-9e59-ecb7e5de2221	2023-07-21 00:00:00	2023-07-29 00:00:00	Full Day		2023-08-10 18:29:45.552729	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	40ec3ce9-19e9-49b6-9e59-ecb7e5de2221
48c2b3d1-ae57-4f2b-a8b5-8493d00a36bb	e387bd09-05b3-475e-81af-d1d1eefd339d	2023-08-09 00:00:00	2023-08-09 00:00:00	Full Day		2023-08-10 18:33:54.488115	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	e387bd09-05b3-475e-81af-d1d1eefd339d
fb56cc5a-f500-489e-b393-e9b042888117	503eab77-e247-421a-8d4a-be6198f3967a	2023-08-11 00:00:00	2023-08-11 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
28768a67-017b-4300-8e03-132a01bce851	503eab77-e247-421a-8d4a-be6198f3967a	2023-08-18 00:00:00	2023-08-18 00:00:00	Half Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
0bda11e4-93f9-47df-b8a0-1360a4e60a14	c4d69cfb-9a10-46b4-8ce9-e82d210eadcd	2023-09-06 00:00:00	2023-09-06 00:00:00	Full Day	Description	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
c5283638-4b84-4537-b0b2-6675984051ba	c4d69cfb-9a10-46b4-8ce9-e82d210eadcd	2023-09-05 00:00:00	2023-09-06 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
1fbad284-f361-49df-be95-7cdb08249218	47888890-cfd0-4060-80d6-a13b1e57d361	2023-09-07 00:00:00	2023-09-07 00:00:00	Half Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
b4335659-ca55-4206-9731-6a68c6433b01	47888890-cfd0-4060-80d6-a13b1e57d361	2023-09-06 00:00:00	2023-09-06 00:00:00	Full Day	Description	2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
64b9d702-ab2d-49bf-b128-5ffc95029f39	d7242008-89c6-4f5b-84b9-44d60fd833e1	2023-09-05 00:00:00	2023-09-06 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
90eb4323-de0b-492f-a2a6-a4a1e9c09700	d7242008-89c6-4f5b-84b9-44d60fd833e1	2023-09-05 00:00:00	2023-09-05 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
9e4c7c5f-2095-4689-9df2-0b6d99332bea	69bd2368-e016-4222-a4ef-ecfaf052adb7	2023-09-05 00:00:00	2023-09-05 00:00:00	Full Day		2023-06-22 18:04:25.933616	2023-06-22 18:04:25.933616	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
\.


                                                                                                                                                                                                                                                                                                                               4162.dat                                                                                            0000600 0004000 0002000 00000000173 14623575606 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2e0ee331-6173-41cc-a1ba-cc21c55e11b6	Adarsh Nagar	50	Active
f9ec6287-6afa-4136-a59a-70bbc5a69d22	Ajay Nagar	30	Active
\.


                                                                                                                                                                                                                                                                                                                                                                                                     4163.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4164.dat                                                                                            0000600 0004000 0002000 00000007550 14623575606 0014275 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        c04cfe19-33e1-45b6-a740-45db3b3adc25	Ambani International School	\N	\N	\N	\N	\N	2024-01-24 16:35:24.937067	2024-01-24 16:35:24.937067	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	06491257-4d99-46f0-81b0-f33878bc6307
e21c641b-8ad5-4b14-b0ff-2971b579f91b	Satguru International School	\N	\N	\N	\N	\N	2024-01-24 16:45:26.688186	2024-01-24 16:45:26.688186	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ebada214-138e-4eba-b938-7ac394de9009
8b598263-5110-4681-8ead-6dc1a4ae1dfb	Satguru International School	\N	4494d388-aa05-4193-97de-ddec8562a568	\N	\N	\N	2024-02-09 13:34:48.53634	2024-02-09 13:34:48.53634	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	18d71109-7211-411c-af07-d9bfbcdc6ed7
caba3d42-e279-41da-be88-13a229c289c8	Ambani International School	\N	\N	\N	\N	\N	2024-02-13 13:00:32.872995	2024-02-13 13:00:32.872995	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	e72c40ac-4479-4573-bf5a-820267e9c177
9df5e187-9021-481f-b2b9-6d92da133242	Satguru International School	\N	91aa892b-28e9-4bb7-a466-6c816bc6d429	A	2021	\N	2024-02-20 16:06:00.276056	2024-02-20 16:06:00.276056	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	85c38908-f672-4c7d-9c9a-7ad2a67789c0
04ae3877-24d1-4b13-bf6c-be7e781ba36f	Ambani International School	\N	\N	\N	\N	\N	2024-02-20 18:52:39.48572	2024-02-20 18:52:39.48572	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	561d6da9-ea96-494c-b308-c17c17f0bb44
68489b5a-8d08-4b52-8a23-95b63c7e880c	Satguru International school	\N	\N	\N	\N	\N	2024-03-22 00:22:56.079823	2024-03-22 00:22:56.079823	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	256c9b96-8ae6-4b42-ac92-272911e9626f
207a3f28-9cd1-4ade-96b3-72c7f5262f77	Satguru International school	\N	\N	\N	\N	\N	2024-04-02 00:05:38.306628	2024-04-02 00:05:38.306628	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	38b3d1d8-8529-42b5-969f-e96d17831fd0
d6212d0a-213e-4c50-b72d-f7cf17d43398	Satguru International school	\N	\N	\N	\N	\N	2024-04-02 00:23:49.714862	2024-04-02 00:23:49.714862	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	7561206d-7c7c-42d5-9ed3-80639443d51f
af165b3d-6fda-4406-988c-93ba471529f7	Satguru International school	\N	\N	\N	\N	\N	2024-04-02 00:24:59.512532	2024-04-02 00:24:59.512532	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ca573d9d-800f-464b-ba75-b413a5b88449
6c504e07-3137-4005-a005-09b6ee30f80c	Satguru International school	\N	\N	\N	\N	\N	2024-04-12 05:28:48.052814	2024-04-12 05:28:48.052814	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	deeecc67-4899-4c5f-a1ad-31324a4ef270
c3689432-42f0-447a-856b-5e9a0b8c5671	Satguru International school	\N	\N	\N	\N	\N	2024-04-12 05:53:50.119126	2024-04-12 05:53:50.119126	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	1287b0c4-731b-490f-bd20-4b47965c4eb6
9dc1e304-1239-4d97-aab3-2e48cdbbbd3d	qrrgsdrgsdtrt	\N	\N	\N	\N	\N	2024-05-10 18:54:47.897984	2024-05-10 18:54:47.897984	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	e8c7b7c3-b42e-48d0-9f03-cb2a18152f9f
36a7d7f8-5ff0-4ce5-930c-b1103cdc73e4	sarkari school	\N	\N	\N	\N	\N	2024-05-13 16:00:26.692363	2024-05-13 16:00:26.692363	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	42d23aac-8501-4cbb-ae7e-4322c4aa7350
0725f9c8-2208-4dfc-9b71-f43b3c5adb03	sarkari school	\N	\N	\N	\N	\N	2024-05-13 16:01:49.572778	2024-05-13 16:01:49.572778	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	790be653-8a57-4ccf-81bb-0469753631ae
8171dfae-3e86-4dea-a0ad-e1ef535c2fa1	sarkari school	\N	\N	\N	\N	\N	2024-05-13 16:09:48.61145	2024-05-13 16:09:48.61145	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	9825b579-83a3-4029-8ada-5fe86a33260e
\.


                                                                                                                                                        4165.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4166.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4167.dat                                                                                            0000600 0004000 0002000 00000001216 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        fd34a0a9-837e-4f37-9712-0491580dda50	cd1ebbed-e3c5-4da8-8eff-4369112571f3	/students	fa-solid fas fa-street-view mx-2	\N	Student_Enquiry
600ac14e-4776-4e0f-8f7a-57ddd4df2198	cd1ebbed-e3c5-4da8-8eff-4369112571f3	/classes	fa-solid fa-chart-simple mx-2	\N	Class
130a4fb5-975e-4e1e-8966-b750d50aba9d	cd1ebbed-e3c5-4da8-8eff-4369112571f3	/student/e	fa-solid fas fa-chart-line mx-2	\N	Students_Registration
47f4116b-561a-4141-ae24-d9aef0bf4be2	cd1ebbed-e3c5-4da8-8eff-4369112571f3	/section	fa-solid fa-chart-simple mx-2	\N	Section
9a79e226-f1ee-4e72-8d70-60decbc99b4f	cd1ebbed-e3c5-4da8-8eff-4369112571f3	/subjects	fa-solid fa-chart-simple mx-2	\N	Subject
\.


                                                                                                                                                                                                                                                                                                                                                                                  4168.dat                                                                                            0000600 0004000 0002000 00000002064 14623575606 0014274 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        8fee596f-6f9d-45e1-a192-9c1e66a102a2	96ca0cb4-2fd5-4575-a2c9-989b0b19dd19	eaa2125f-aca6-4779-a063-1e878616bf90	55	t	83d251bc-bb97-4f86-8190-311d379cf63f
b1874376-bad2-484a-9900-94caa33db7c2	96ca0cb4-2fd5-4575-a2c9-989b0b19dd19	a097b85f-7268-46fd-9640-4734a320cc97	67	t	87eb2d6e-525c-45c8-b6d1-a12b1896a592
98304463-1485-48a3-b4e1-9c6408f2c65f	96ca0cb4-2fd5-4575-a2c9-989b0b19dd19	a36f3def-06e4-4080-a895-02163a263de9	44	t	1fbc123f-8d30-429c-b090-1f2c0067ac77
22811683-4181-4234-a114-bb14de8c195f	96ca0cb4-2fd5-4575-a2c9-989b0b19dd19	e38dd3e5-a217-4688-9cc7-d0a4b3d83b62	34	t	7c30b848-233a-4b3b-9126-84ff79078158
1cbcba8d-9400-4319-ab56-8780d82e48c4	82c93ebe-7ac4-4c4b-b278-66ae64995fa8	b38232c9-043f-4752-b93c-d3d999e86d8e	75	t	83d251bc-bb97-4f86-8190-311d379cf63f
f9913cfd-a58b-4187-814c-d3c930573284	82c93ebe-7ac4-4c4b-b278-66ae64995fa8	e38dd3e5-a217-4688-9cc7-d0a4b3d83b62	70	t	83d251bc-bb97-4f86-8190-311d379cf63f
50781b6d-3351-479f-8731-c84d224dff58	82c93ebe-7ac4-4c4b-b278-66ae64995fa8	08c9a10b-9ead-4f9f-b153-9d5b6a63e6e0	50	t	1fbc123f-8d30-429c-b090-1f2c0067ac77
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                            4169.dat                                                                                            0000600 0004000 0002000 00000000530 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        3b188de1-052e-417b-ac39-60e4ecf7ebb3	f9ec6287-6afa-4136-a59a-70bbc5a69d22	552519d7-6c36-4975-9c73-551116651c31	3
c230029f-4f5c-4c12-8394-4c3a975deaaf	2e0ee331-6173-41cc-a1ba-cc21c55e11b6	37ac25b7-5d3b-419f-9c62-7064b1991b33	1
66b7b886-9e74-4509-88e8-5cc35cb71dc3	f9ec6287-6afa-4136-a59a-70bbc5a69d22	a25f8054-f899-48a8-844c-a7ad1744e7a0	5
\.


                                                                                                                                                                        4170.dat                                                                                            0000600 0004000 0002000 00000016110 14623575606 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        df76e7e5-a14e-4d91-a411-7efa1fff5300	A	265f5e95-f0a3-4750-9e95-9eb1f42fe2fd	100	2023-10-27 13:01:00.803555	2023-10-27 13:01:00.803555	\N	\N	\N	t
a7d02f7b-4a4a-4bdc-96c4-91dbbfd5aaae	B	05f270df-4556-447f-86cf-fedd96ea1592	180	2023-10-31 13:10:10.87724	2023-10-31 13:10:10.87724	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	caf31e4b-0cd7-4499-b4a2-5c99f1b0838f	\N
2a1f3d74-1c6b-4f27-9bee-65946726b476	D	90d514b0-652d-4fc9-a051-6d8f4d2df6d6	240	2023-10-31 13:12:58.660523	2023-10-31 13:12:58.660523	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	742fbd1c-32b7-462e-b73b-dde1c04f588f	\N
159ac39e-5d8d-42f9-b24e-dd8dd276cd7e	E	5bc6f9a6-fa68-46f3-80f0-362a95d4f259	22	2023-11-06 12:43:00.680119	2023-11-06 12:42:25.237881	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	64af269f-0e02-4f14-a7c3-50a7d74ff57f	\N
6b68b517-3d05-4f04-a7e6-fd1ba13d185a	A	df65972a-3ed4-4db3-92ba-1aed0794f0e0	50	2023-11-09 16:28:25.708691	2023-11-06 11:13:31.988592	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
a4ca7ae7-97a5-4962-b187-bffd60b8f4ee	A	61724501-a791-40f4-8ab9-ad908af677b9	22	2023-11-09 16:28:51.063379	2023-11-09 16:28:51.063379	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	1b75aa46-6b27-494a-a846-7e19215ebd24	\N
91c2dfea-f630-4a75-95e4-d94ca1f6b348	E	60795019-968d-409a-80c6-0e5705f6a51f	51	2023-11-09 16:29:48.94483	2023-10-12 17:58:14.684005	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
62d2fb78-7dc7-4de1-8a0d-83d5b1b616b4	A	d5c4da8b-1b01-426f-8b18-403d9beaf537	240	2023-11-09 16:31:20.916395	2023-10-25 17:59:45.311566	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
a1c8276b-792d-457e-9e89-f1cfdffe5a23	D	60795019-968d-409a-80c6-0e5705f6a51f	220	2023-11-20 15:43:59.260454	2023-10-12 11:28:32.821486	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
a2d33863-ff92-49de-ab2c-e08f6643d0e4	B	60795019-968d-409a-80c6-0e5705f6a51f	22	2023-11-20 15:44:07.494649	2023-09-05 13:47:55.988899	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
cd36a2c7-3f37-4320-827b-ab2cf6e6eb29	A	60795019-968d-409a-80c6-0e5705f6a51f	21	2023-11-21 11:27:39.22193	2023-09-05 13:47:38.001064	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
b41abc28-7411-482d-b6f3-0a820a262179	A	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	50	2024-01-18 15:59:21.943045	2023-09-05 15:19:11.66298	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	1b75aa46-6b27-494a-a846-7e19215ebd24	t
e0fdd79a-927f-4f45-8ca1-61af87a8da6b	A	4494d388-aa05-4193-97de-ddec8562a568	45	2024-01-18 16:05:13.418141	2023-10-31 16:53:57.306026	\N	cd1ebbed-e3c5-4da8-8eff-4369112571f3	8ca650bc-a109-477d-81c4-6b0334e40163	t
63b2ce53-5a5d-4ba3-bc67-8c1091128247	A	6fe5f267-1414-4113-9474-86722189d0e6	40	2024-02-20 18:47:53.712938	2023-10-10 15:52:43.780153	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	t
39553e42-6106-4e65-a51c-fb6ff162d354	E	91aa892b-28e9-4bb7-a466-6c816bc6d429	50	2024-05-15 16:44:32.108073	2023-11-06 12:37:23.258584	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	8d377acf-d219-4ca0-8c0b-91726f5f2254	t
0cca35dd-db81-48ab-8f86-dd8ad76b6756	D	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	82	2024-05-15 17:01:19.842782	2023-10-30 10:47:30.631322	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	41d0bb34-d49b-46e3-a15c-e05940234f82	t
a86ff674-d053-4883-9d29-1d1b60ca9c26	AB	8b37c8d3-ff0f-48c5-b7ae-436707436b32	45	2024-05-16 10:54:12.977843	2024-05-16 10:53:25.944537	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	23b78f9f-fbfe-4e3c-b5b5-effaf60d813d	t
93031a68-743e-42fb-b82f-06f14b726c2a	k	91aa892b-28e9-4bb7-a466-6c816bc6d429	7	2024-05-16 17:50:07.772069	2024-05-16 17:50:07.772069	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
f995ffbe-78bb-4e6d-9dfc-909545271741	z	91aa892b-28e9-4bb7-a466-6c816bc6d429	1	2024-05-16 18:20:03.970286	2024-05-16 18:19:22.457756	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	fcf9308d-c914-4469-a3f3-0734a49e0fce	t
24a55358-406d-4687-83f0-99fd91a28dea	B	91aa892b-28e9-4bb7-a466-6c816bc6d429	100	2024-05-17 10:15:40.049826	2024-05-17 10:15:40.049826	\N	\N	\N	t
799a5af8-652b-4a6c-b366-f8b42f2f5d5c	RS	4494d388-aa05-4193-97de-ddec8562a568	12	2024-05-17 12:53:19.536833	2024-05-17 12:53:19.536833	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
ded2210b-ff07-4f83-845e-5a02f843915e	B	61724501-a791-40f4-8ab9-ad908af677b9	3	2024-05-17 15:14:44.510722	2024-05-17 15:14:44.510722	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
e759b9b0-cbd5-4199-9582-86c3b4be79b7	C	61724501-a791-40f4-8ab9-ad908af677b9	3	2024-05-17 15:15:28.00943	2024-05-17 15:15:28.00943	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
a1240bd2-f526-43a5-9aeb-bf7f0fd8665e	D	61724501-a791-40f4-8ab9-ad908af677b9	4	2024-05-17 15:18:43.722763	2024-05-17 15:18:43.722763	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
f2a7400f-340f-4fd3-80dd-cecbaf344f91	F	61724501-a791-40f4-8ab9-ad908af677b9	3	2024-05-17 15:19:35.165646	2024-05-17 15:19:35.165646	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
6177cd32-088e-482e-ad3c-150b15915458	G	60795019-968d-409a-80c6-0e5705f6a51f	27	2024-05-17 16:35:50.870286	2023-10-12 11:11:35.710466	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	fcf9308d-c914-4469-a3f3-0734a49e0fce	t
4ceb8988-6365-4fed-8be5-ec05761171ff	C	60795019-968d-409a-80c6-0e5705f6a51f	23	2024-05-17 16:48:21.57573	2024-05-17 16:48:21.57573	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
41fa9452-25a3-4ac9-b300-f9c952633361	F	60795019-968d-409a-80c6-0e5705f6a51f	88	2024-05-17 16:49:16.702961	2024-05-17 16:49:16.702961	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	7e4220c3-4283-4aff-a56a-12beaa0c862a	\N
8914ed36-656c-46a6-8d0e-3027dbe00e27	C	91aa892b-28e9-4bb7-a466-6c816bc6d429	8	2024-05-17 16:51:33.348262	2024-05-17 16:51:33.348262	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
16552457-b1a6-4191-a42a-c57c7707766a	D	91aa892b-28e9-4bb7-a466-6c816bc6d429	8	2024-05-17 16:52:51.8514	2024-05-17 16:52:51.8514	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
01082dc0-25ec-488c-b482-1dc18770b7c6	F	91aa892b-28e9-4bb7-a466-6c816bc6d429	7	2024-05-17 16:53:25.987983	2024-05-17 16:50:31.654269	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
74af66c9-d438-42d0-805d-41f889880254	H	91aa892b-28e9-4bb7-a466-6c816bc6d429	82	2024-05-17 16:54:27.629424	2024-05-16 17:49:48.866891	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
86a793e6-1657-47e6-a7d2-0d204056d359	G	91aa892b-28e9-4bb7-a466-6c816bc6d429	1	2024-05-17 16:55:03.894691	2024-05-17 16:54:12.33877	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	\N
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                        4171.dat                                                                                            0000600 0004000 0002000 00000000324 14623575606 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        76fe9937-ecdd-4abf-bad1-6e630e8ee8ea	2022-2023	2021-01-01	2022-12-01
c39ee366-9941-4fbd-92a2-13107e898003	2023-2024	2022-01-01	2023-12-01
76dee1ce-3881-4a3f-a84e-6c227f7fa13b	2024-2025	2024-12-06	2025-12-04
\.


                                                                                                                                                                                                                                                                                                            4172.dat                                                                                            0000600 0004000 0002000 00000000207 14623575606 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        3d21eb56-7e8e-4860-b242-edc374bd4b2b	late_fee	100	\N	\N	\N	\N
38aaca25-cdf2-4bea-9e24-762fcb916719	pending_due_day	10	\N	\N	\N	\N
\.


                                                                                                                                                                                                                                                                                                                                                                                         4174.dat                                                                                            0000600 0004000 0002000 00000006014 14623575606 0014270 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        7561206d-7c7c-42d5-9ed3-80639443d51f	Aman	Gupta	SR-00022	\N	2024-04-01	male	aman@gmail.com	\N	123	\N	\N	\N	\N	\N	61724501-a791-40f4-8ab9-ad908af677b9	\N	5bb154dd-365b-4041-922f-82ddf473bdb1	\N	2024-04-02 00:23:49.653293	2024-04-02 00:23:49.653293	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	\N	\N	\N	\N	\N	\N	c39ee366-9941-4fbd-92a2-13107e898003	General
ca573d9d-800f-464b-ba75-b413a5b88449	Hemant	Jangir	SR-00023	\N	2024-04-01	male	\N	\N	1234	\N	\N	\N	\N	\N	91aa892b-28e9-4bb7-a466-6c816bc6d429	\N	b6da9859-67d5-46d1-9e53-b54ac93f4e67	\N	2024-04-02 00:24:59.458054	2024-04-02 00:24:59.458054	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	\N	\N	\N	\N	\N	\N	c39ee366-9941-4fbd-92a2-13107e898003	Obc
deeecc67-4899-4c5f-a1ad-31324a4ef270	Yashika	\N	SR-00024	\N	\N	\N	\N	\N	5555	\N	\N	\N	\N	\N	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	\N	08f73050-2532-4f79-914d-211a62c8419e	\N	2024-04-12 05:28:47.998821	2024-04-12 05:28:47.998821	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	\N	\N	\N	\N	\N	\N	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	General
1287b0c4-731b-490f-bd20-4b47965c4eb6	GK	khan	SR-00025	Religion	2024-04-07	male	testclass2003@yopmail.com	656567876543	90909876	202004	Street no 12	Ajmer	Raj	India	8e6c18b4-0810-4f95-abb0-3a733c613ecb	Description	\N	552519d7-6c36-4975-9c73-551116651c31	2024-04-12 05:53:50.064009	2024-04-12 05:53:50.064009	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	Street no 12	Ajmer	202004	Raj	India	\N	c39ee366-9941-4fbd-92a2-13107e898003	Obc
42d23aac-8501-4cbb-ae7e-4322c4aa7350	shivam	\N	SR-00027	\N	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	61724501-a791-40f4-8ab9-ad908af677b9	\N	840e8bb0-14f3-4367-84c0-934a21f51329	\N	2024-05-13 16:00:26.667378	2024-05-13 16:00:26.667378	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	\N	\N	\N	\N	\N	\N	\N	General
790be653-8a57-4ccf-81bb-0469753631ae	shivam	\N	SR-00028	\N	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	61724501-a791-40f4-8ab9-ad908af677b9	\N	06f4df84-10c0-4332-9be9-158c3276f206	\N	2024-05-13 16:01:49.538752	2024-05-13 16:01:49.538752	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	\N	\N	\N	\N	\N	\N	\N	General
9825b579-83a3-4029-8ada-5fe86a33260e	shivam	\N	SR-00029	\N	\N	\N	\N	\N	2345768654	\N	\N	\N	\N	\N	61724501-a791-40f4-8ab9-ad908af677b9	\N	79424874-8255-4d1d-8cca-3fbd3bde2b9c	\N	2024-05-13 16:09:48.555078	2024-05-13 16:09:48.555078	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	\N	\N	\N	\N	\N	\N	\N	General
e8c7b7c3-b42e-48d0-9f03-cb2a18152f9f	sadf	asdfsdf	SR-00026	Religion	2024-04-07	male	test@gmail.com	431256552323	423534	2345234	fdsafsdg34	jaipur	Raj	India	91aa892b-28e9-4bb7-a466-6c816bc6d429	desc	08f73050-2532-4f79-914d-211a62c8419e	552519d7-6c36-4975-9c73-551116651c31	2024-05-10 18:54:47.874701	2024-05-10 18:54:47.874701	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f	fasfasfg	jaipur	23452345	Raj	India	\N	c39ee366-9941-4fbd-92a2-13107e898003	General
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    4176.dat                                                                                            0000600 0004000 0002000 00000005327 14623575606 0014300 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        86d618d6-682d-4168-8e78-60c5fc9265a6	7561206d-7c7c-42d5-9ed3-80639443d51f	61724501-a791-40f4-8ab9-ad908af677b9	2023-02-04		2024-04-02 00:23:49.748659	2024-04-02 00:23:49.748659	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0035	5bb154dd-365b-4041-922f-82ddf473bdb1	f	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	3fe255ed-1633-4b21-af0a-f607638f0ae4
f3232c4b-6d81-48ec-9fcc-4d5441a80b27	ca573d9d-800f-464b-ba75-b413a5b88449	91aa892b-28e9-4bb7-a466-6c816bc6d429	2023-02-04		2024-04-02 00:24:59.539801	2024-04-02 00:24:59.539801	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0036	b6da9859-67d5-46d1-9e53-b54ac93f4e67	f	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	3fe255ed-1633-4b21-af0a-f607638f0ae4
f9a15543-f743-41e9-abd1-5edc60e9141f	deeecc67-4899-4c5f-a1ad-31324a4ef270	8b3e2cc0-5b44-44f5-b1ae-d9aa99156727	2023-02-04		2024-04-12 05:28:48.082623	2024-04-12 05:28:48.082623	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0037	08f73050-2532-4f79-914d-211a62c8419e	f	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	3fe255ed-1633-4b21-af0a-f607638f0ae4
5f009d88-43ec-4209-abe8-f932510ea377	1287b0c4-731b-490f-bd20-4b47965c4eb6	8e6c18b4-0810-4f95-abb0-3a733c613ecb	2023-02-04		2024-04-12 05:53:50.155577	2024-04-12 05:53:50.155577	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0038	\N	f	76dee1ce-3881-4a3f-a84e-6c227f7fa13b	3fe255ed-1633-4b21-af0a-f607638f0ae4
8977ec2c-2726-4de5-8d3b-1529e6f2d6f2	e8c7b7c3-b42e-48d0-9f03-cb2a18152f9f	91aa892b-28e9-4bb7-a466-6c816bc6d429	2023-02-04		2024-05-10 18:54:47.91244	2024-05-10 18:54:47.91244	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0039	\N	f	\N	3fe255ed-1633-4b21-af0a-f607638f0ae4
be399674-30b9-477f-80fd-14fadb3ef231	42d23aac-8501-4cbb-ae7e-4322c4aa7350	61724501-a791-40f4-8ab9-ad908af677b9	2023-02-04		2024-05-13 16:00:26.711807	2024-05-13 16:00:26.711807	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0040	840e8bb0-14f3-4367-84c0-934a21f51329	f	\N	0323aad4-7e7f-4ac4-bda9-1cda89bd6472
60676c56-310b-4d7f-81aa-000ffba03990	790be653-8a57-4ccf-81bb-0469753631ae	61724501-a791-40f4-8ab9-ad908af677b9	2023-02-04		2024-05-13 16:01:49.662427	2024-05-13 16:01:49.662427	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0041	06f4df84-10c0-4332-9be9-158c3276f206	f	\N	0323aad4-7e7f-4ac4-bda9-1cda89bd6472
1f11ba98-c468-4d3a-b623-5a7efa1ea86e	9825b579-83a3-4029-8ada-5fe86a33260e	61724501-a791-40f4-8ab9-ad908af677b9	2023-02-04		2024-05-13 16:09:48.632161	2024-05-13 16:09:48.632161	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	ST-0042	79424874-8255-4d1d-8cca-3fbd3bde2b9c	f	\N	0323aad4-7e7f-4ac4-bda9-1cda89bd6472
\.


                                                                                                                                                                                                                                                                                                         4177.dat                                                                                            0000600 0004000 0002000 00000006500 14623575606 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        08184e9a-b967-495c-8a8f-e39653622878	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	cec5ac92-94bb-4776-b5a7-bd77b9da1390	1500	\N	\N	\N	pending	\N	1	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.839194	2024-05-01 16:44:49.839194	\N	\N	April	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
eaa10a70-bbd3-4eeb-9359-9484c41d8d36	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	6977e5a0-ba3f-4d25-ad4a-8a02701527dd	1500	\N	\N	\N	pending	\N	2	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.85617	2024-05-01 16:44:49.85617	\N	\N	May	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
f244fc50-d25d-4a35-a461-59be322faafc	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	1cf34f61-85f5-4a0e-8f98-ad1d040dfa9f	1500	\N	\N	\N	pending	\N	3	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.871884	2024-05-01 16:44:49.871884	\N	\N	June	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
25f60441-1b20-4b98-a008-f992fd0be943	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	da6b799f-c925-4963-b72d-d583fc26cdc4	1500	\N	\N	\N	pending	\N	4	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.890465	2024-05-01 16:44:49.890465	\N	\N	July	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
00414963-74bc-4d7d-8be0-7276e4a79897	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	ce24ed52-dfe8-4fc4-b926-3d9829e74b8a	1500	\N	\N	\N	pending	\N	5	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.932874	2024-05-01 16:44:49.932874	\N	\N	August	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
a3e4a71a-3483-4362-98db-34a319bdf894	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	2484f4ac-acc0-452f-bd10-d27a998a2c77	1500	\N	\N	\N	pending	\N	6	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.949673	2024-05-01 16:44:49.949673	\N	\N	September	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
152f353f-d9a0-4637-9137-3f061a7f2f27	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	55b3d166-b321-4015-b441-91fb8d5b19ae	1500	\N	\N	\N	pending	\N	7	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.966228	2024-05-01 16:44:49.966228	\N	\N	October	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
feb5a9b9-c3a1-4d59-a9bc-561ef4880742	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	23421426-cdcf-40bb-9c60-271388a341d7	1500	\N	\N	\N	pending	\N	8	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:49.983226	2024-05-01 16:44:49.983226	\N	\N	November	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
aba8d8d8-2655-4484-bb38-d47fa2e70a61	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	c7c30ebd-f554-48d5-97b6-a8f0d4d8ccbd	1500	\N	\N	\N	pending	\N	9	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:50.000213	2024-05-01 16:44:50.000213	\N	\N	December	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
cd484a7c-6669-410d-8ca6-f020c2ba1018	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	47cbec18-8ad2-4ff1-b9e7-3918a99bff1c	1500	\N	\N	\N	pending	\N	10	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:50.021846	2024-05-01 16:44:50.021846	\N	\N	January	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
e9be5e76-d461-49f0-853f-e5d3ab1919a9	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	a4481c08-ce36-4178-98d9-2f3c2c8e882c	1500	\N	\N	\N	pending	\N	11	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:50.050961	2024-05-01 16:44:50.050961	\N	\N	February	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
54133d5e-c65e-4546-abc3-c52e7f627c03	c44ad787-9534-4a3b-b3ce-fce9dd8a32fb	a6a969d2-63e3-4227-a27d-3a1196b3ae73	1500	\N	\N	\N	pending	\N	12	b89873b1-4e02-4c22-982d-7692c4c7a414	59	2024-05-01 16:44:50.067918	2024-05-01 16:44:50.067918	\N	\N	March	76dee1ce-3881-4a3f-a84e-6c227f7fa13b
\.


                                                                                                                                                                                                4178.dat                                                                                            0000600 0004000 0002000 00000005665 14623575606 0014307 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        08ad91fd-c83b-46ca-b78a-3b6f439e4fe7	C++ Lab	2024-03-01 13:30:14.481522	2024-03-01 13:30:14.481522	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	CL-SC	Active
61cc1660-c4d8-444c-bcea-a94283a6620b	Sanskrit	2023-11-06 11:04:10.562052	2023-11-06 11:04:10.562052	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	SAN	Active
649c49a6-91c2-4659-950f-733b64f556c5	Maths	2023-11-01 18:09:23.814352	2023-11-01 18:09:23.814352	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	MAT	Active
6a2bfda8-0c45-4330-a342-fb3e38e9cd7c	Hin	2024-02-01 13:15:36.191516	2024-02-01 13:15:36.191516	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	HIN-SC	Active
b9d2fb47-617d-4e33-bbfe-17abe5a5c486	Science	2023-11-01 18:09:57.429933	2023-11-01 18:09:57.429933	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	SCI	InActive
e06efc22-b276-45da-8de0-af656c859697	Hindi	2023-10-09 15:12:05.102688	2023-10-09 15:12:05.102688	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	hin	InActive
08124c21-c903-4c05-a864-26611bb2cc7c	English	2023-10-09 09:53:02.209	2023-10-09 09:53:02.209	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	eng	Active
7cd16451-290f-4fca-b90b-c8a6973f9e6c	Social Science	2023-06-20 07:35:06.828	2023-06-20 07:35:06.828	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	General	SS	InActive
059d27fe-f486-4dbf-8c99-1b261619928e	C++	2024-03-01 13:30:29.395897	2024-03-01 13:30:29.395897	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	Scholastic	Optional	C++	Active
d89ebf8d-3ddf-4404-98c2-ccfec308e968	Social Science	2024-04-09 05:10:19.80423	2024-04-09 05:10:19.80423	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	Optional	SS	Active
22a0ced6-d738-43d8-b6d0-704364e6596d	GK	2024-04-09 05:11:00.103463	2024-04-09 05:11:00.103463	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	Optional	GK	Active
83bb6577-e5dc-48e7-be4e-d8e33cda7705	Scient	2024-04-11 23:57:07.321851	2024-04-11 23:57:07.321851	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	General	SCI	Active
ea9f88ae-fa2c-4e8c-a000-3f19736456ee	java c	2024-05-16 17:58:53.493835	2024-05-16 17:58:53.493835	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	General	JC	Active
2b5cbfac-4c2a-4e3b-b8ee-839a52fa20d3	asd	2024-05-16 17:59:06.040468	2024-05-16 17:59:06.040468	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	Optional	ASD	InActive
32f222e9-e8a7-4efb-b6fc-65a101bfa8b5	c java hindi	2024-05-16 18:06:02.048672	2024-05-16 18:06:02.048672	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N	General	CJ	Active
\.


                                                                           4179.dat                                                                                            0000600 0004000 0002000 00000012355 14623575606 0014302 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        59dc7bd1-936b-463e-8449-0172d962b3aa	acf02ccb-f0e3-4b6a-b757-46d2db235e31	6dff4a21-81c3-484d-aa4a-c40df5ca85ca	2023-06-20 14:14:11.872126	2023-06-20 14:14:11.872126	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
deba3e8e-bbd5-4340-a830-fc9f9cb01902	acf02ccb-f0e3-4b6a-b757-46d2db235e31	031bc5e6-4afe-4c11-8e69-a2887398181e	2023-06-20 14:25:04.39407	2023-06-20 14:25:04.39407	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
5d1fe482-bd3a-493c-a59c-33a156b16da2	07fbd8f4-ca8f-4def-83fd-a6be4174e034	031bc5e6-4afe-4c11-8e69-a2887398181e	2023-07-11 18:52:43.68884	2023-07-11 18:52:43.68884	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
1a7e5c20-8fe0-4afd-813e-4e5936c98238	b85c2697-3e11-4333-9bbe-eb3e8ffeee4f	7cd16451-290f-4fca-b90b-c8a6973f9e6c	2023-07-12 15:14:04.276473	2023-07-12 15:14:04.276473	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
9e2360bf-5519-4293-af40-dddf1dfa5a39	b2f100e5-347e-4fa6-be89-6b0b507b4128	fd60f132-913b-4223-b314-a3a8f43f7f69	2023-07-17 10:45:40.657223	2023-07-17 10:45:40.657223	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
8fb05306-dd26-4d3e-9b7d-cb6395df0b81	f7cc0903-a529-4470-9b7d-e4c8f41c0249	875fd449-6309-49eb-b7d3-252161cb0255	2023-07-17 10:48:35.178764	2023-07-17 10:48:35.178764	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
0aecc076-d762-4bdf-9958-a037711fb540	7cec2720-593c-4456-9262-041cb228be90	d4c1cad0-4931-47ed-88a2-944291441dd0	2023-07-18 11:20:55.825042	2023-07-18 11:20:55.825042	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
4c043162-c6f0-40b3-af42-345f2388f88a	b85c2697-3e11-4333-9bbe-eb3e8ffeee4f	7cd16451-290f-4fca-b90b-c8a6973f9e6c	2023-07-25 18:03:52.624454	2023-07-25 18:03:52.624454	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	91aa892b-28e9-4bb7-a466-6c816bc6d429
38818d3c-7c14-4180-8f6f-73d509aa5e6a	ebc66f73-fc95-40dd-ba85-5ac5622cdda1	fd60f132-913b-4223-b314-a3a8f43f7f69	2023-07-25 18:04:57.805584	2023-07-25 18:04:57.805584	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	f40ca4a6-758f-41fd-8857-323b2575ee7a
003f280f-4782-4402-b383-a4875b72296f	054be25c-1674-4188-85e7-072e1aab4551	fd60f132-913b-4223-b314-a3a8f43f7f69	2023-07-25 18:05:28.309685	2023-07-25 18:05:28.309685	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
bb8e0fef-5afb-4e4e-b372-976a80772c38	054be25c-1674-4188-85e7-072e1aab4551	\N	2023-07-25 18:12:42.29118	2023-07-25 18:12:42.29118	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
f805108a-ec07-4a4e-bf5a-e24f4b731844	\N	\N	2023-07-25 18:21:58.649775	2023-07-25 18:21:58.649775	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
a019b855-226a-41b7-a428-3bfd9a6d0b93	\N	\N	2023-07-25 18:22:30.989727	2023-07-25 18:22:30.989727	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
8367f14b-6bf6-449b-a39a-1a1775678ab3	\N	\N	2023-07-25 18:31:52.499979	2023-07-25 18:31:52.499979	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	fa6ffe70-e607-44c0-8980-6e74c102dcbc
e6ce39f1-75ca-4bec-864b-38fdf7b6d1cd	ebc66f73-fc95-40dd-ba85-5ac5622cdda1	\N	2023-07-25 20:14:21.587865	2023-07-25 20:14:21.587865	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
7e0dbc2c-fe29-4553-bf20-4b405b9a4b17	054be25c-1674-4188-85e7-072e1aab4551	d4c1cad0-4931-47ed-88a2-944291441dd0	2023-07-26 15:26:13.434133	2023-07-26 15:26:13.434133	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	60795019-968d-409a-80c6-0e5705f6a51f
3f381f8b-bb99-449a-a9a9-89ab999290f0	47888890-cfd0-4060-80d6-a13b1e57d361	fbbb3e61-475d-4129-9f64-f408118d18f5	2023-08-10 18:07:36.132051	2023-08-10 18:07:36.132051	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	60795019-968d-409a-80c6-0e5705f6a51f
25bd3d8a-46a3-4b8e-97db-1a6daeb968a6	c4d69cfb-9a10-46b4-8ce9-e82d210eadcd	fbbb3e61-475d-4129-9f64-f408118d18f5	2023-08-25 19:56:59.979243	2023-08-25 19:56:59.979243	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	60795019-968d-409a-80c6-0e5705f6a51f
840f4e8d-f984-4088-893d-1cc6f0daeb42	47888890-cfd0-4060-80d6-a13b1e57d361	7cd16451-290f-4fca-b90b-c8a6973f9e6c	2023-09-04 16:41:50.844143	2023-09-04 16:41:50.844143	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	91aa892b-28e9-4bb7-a466-6c816bc6d429
bc37f2e8-ee0a-41f1-8750-5c283b47f281	c4d69cfb-9a10-46b4-8ce9-e82d210eadcd	7cd16451-290f-4fca-b90b-c8a6973f9e6c	2023-09-05 11:07:31.09881	2023-09-05 11:07:31.09881	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	60795019-968d-409a-80c6-0e5705f6a51f
790ee254-584a-4220-8f3a-240c53ebd796	\N	\N	2023-09-05 11:28:26.062817	2023-09-05 11:28:26.062817	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
a87c49ee-8f79-4f97-af94-acea82ab122c	\N	\N	2023-09-05 12:48:24.788121	2023-09-05 12:48:24.788121	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
aefa9f0e-9457-4d33-b56a-3132c202baa7	\N	\N	2023-09-05 12:49:03.96356	2023-09-05 12:49:03.96356	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
\.


                                                                                                                                                                                                                                                                                   4180.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4181.dat                                                                                            0000600 0004000 0002000 00000001743 14623575606 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        b65ec969-8380-4d0d-9f94-a7962e737ad6	60795019-968d-409a-80c6-0e5705f6a51f	b41abc28-7411-482d-b6f3-0a820a262179	08124c21-c903-4c05-a864-26611bb2cc7c	2023-24 CBSE Class 1 English Syllabus\nCBSE Class 1 students can download the latest Class 1 English Syllabus PDF for the academic year 2023-24 from the link above. Moreover, they can have a look at the chapter names which are covered under the English Syllabus of Class 1.\n\nCBSE Class 1 English Marigold 1 Chapter Name\nUnit 1: A Happy Child\n\nThree Little Pigs\n\nUnit 2: After a Bath\n\nThe Bubble, the Straw and the Shoe\n\nUnit 3: One Little Kitten\n\nLalu and Peelu\n\nUnit 4: Once I Saw a Little Bird\n\nMittu and the Yellow Mango\n\nUnit 5: Merry-Go-Round\n\nCircle\n\nUnit 6: If I Were an Apple\n\nOur Tree\n\nUnit 7: A Kite\n\nSundari\n\nUnit 8: A Little Turtle\n\nThe Tiger and the Mosquito\n\nUnit 9: Clouds\n\nAnandiâs Rainbow\n\nUnit 10: Flying Man\n\nThe Tailor and his Friend.	c39ee366-9941-4fbd-92a2-13107e898003	Active
\.


                             4182.dat                                                                                            0000600 0004000 0002000 00000001634 14623575606 0014272 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        0658dd42-2476-4c5f-a289-0baa0f0ca9d0	Assembly	07:00	08:00	active	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
94fc181c-457a-4458-8f57-ffa1be0192d5	Break	10:00	11:00	active	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
1898e0f0-e234-4132-bf89-0be782168d67	Period 1	08:00	09:00	active	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
45348e5f-9c8e-4bda-be06-1e669ce7eaf8	Period 2	09:00	10:00	active	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	\N
3a65ae9e-e243-470e-8231-0e2ea38d122b	Period 3	11:00	12:00	active	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
c3497ec7-2540-467f-aeb2-b06086c64dc5	Period 4	12:00	13:00	inactive	cd1ebbed-e3c5-4da8-8eff-4369112571f3	cd1ebbed-e3c5-4da8-8eff-4369112571f3	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
\.


                                                                                                    4183.dat                                                                                            0000600 0004000 0002000 00000005205 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        d3a6f3ed-72d5-4423-869f-f197950d1778	265f5e95-f0a3-4750-9e95-9eb1f42fe2fd	8d377acf-d219-4ca0-8c0b-91726f5f2254	649c49a6-91c2-4659-950f-733b64f556c5	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-08 23:59:25.977465	2024-04-08 23:59:25.977465	\N	\N	df76e7e5-a14e-4d91-a411-7efa1fff5300	\N	\N	\N	Tuesday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
941cafd0-d2aa-49b5-a81b-9041833f2099	60795019-968d-409a-80c6-0e5705f6a51f	e8e8c15b-d86e-4e75-8674-86ddf95d02c9	61cc1660-c4d8-444c-bcea-a94283a6620b	94fc181c-457a-4458-8f57-ffa1be0192d5	2024-04-19 00:36:07.864679	2024-04-19 00:36:07.864679	\N	\N	91c2dfea-f630-4a75-95e4-d94ca1f6b348	\N	\N	\N	Tuesday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
0d3aaf22-b96a-4ad7-ad22-833d44377cb6	60795019-968d-409a-80c6-0e5705f6a51f	fcf9308d-c914-4469-a3f3-0734a49e0fce	649c49a6-91c2-4659-950f-733b64f556c5	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-19 00:35:53.614458	2024-04-19 00:35:53.614458	\N	\N	91c2dfea-f630-4a75-95e4-d94ca1f6b348	\N	\N	\N	Monday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
39421b4a-a2d8-4541-a4ae-15e11e35141b	60795019-968d-409a-80c6-0e5705f6a51f	23b78f9f-fbfe-4e3c-b5b5-effaf60d813d	08124c21-c903-4c05-a864-26611bb2cc7c	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-15 06:28:44.776626	2024-04-15 06:28:44.776626	\N	\N	6177cd32-088e-482e-ad3c-150b15915458	\N	\N	\N	Monday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
f14417a6-17ee-4174-98c2-4f4b2025d674	60795019-968d-409a-80c6-0e5705f6a51f	41d0bb34-d49b-46e3-a15c-e05940234f82	08ad91fd-c83b-46ca-b78a-3b6f439e4fe7	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-15 06:50:08.705405	2024-04-15 06:50:08.705405	\N	\N	6177cd32-088e-482e-ad3c-150b15915458	\N	\N	\N	Wednesday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
4958b05e-9b93-434a-993a-5dbbf6372c85	265f5e95-f0a3-4750-9e95-9eb1f42fe2fd	e8e8c15b-d86e-4e75-8674-86ddf95d02c9	e06efc22-b276-45da-8de0-af656c859697	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-08 23:47:15.883449	2024-04-08 23:47:15.883449	\N	\N	df76e7e5-a14e-4d91-a411-7efa1fff5300	\N	\N	\N	Monday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
c537f220-21b1-4387-a289-7dab01e0b6fb	60795019-968d-409a-80c6-0e5705f6a51f	e8e8c15b-d86e-4e75-8674-86ddf95d02c9	e06efc22-b276-45da-8de0-af656c859697	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-23 22:51:38.207052	2024-04-23 22:51:38.207052	\N	\N	6177cd32-088e-482e-ad3c-150b15915458	\N	\N	\N	Thursday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
410fbde9-6d38-4c18-9a5b-958de386d11a	60795019-968d-409a-80c6-0e5705f6a51f	742fbd1c-32b7-462e-b73b-dde1c04f588f	b9d2fb47-617d-4e33-bbfe-17abe5a5c486	0658dd42-2476-4c5f-a289-0baa0f0ca9d0	2024-04-15 06:29:12.180137	2024-04-15 06:29:12.180137	\N	\N	6177cd32-088e-482e-ad3c-150b15915458	\N	\N	\N	Tuesday	76fe9937-ecdd-4abf-bad1-6e630e8ee8ea
\.


                                                                                                                                                                                                                                                                                                                                                                                           4184.dat                                                                                            0000600 0004000 0002000 00000001023 14623575606 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        37ac25b7-5d3b-419f-9c62-7064b1991b33	063df397-2605-458d-8400-d89bc373f6a6	12334	van	66	Active	f9ec6287-6afa-4136-a59a-70bbc5a69d22
42ce159e-2cd4-46b0-ba6f-0d8f1a74afa5	063df397-2605-458d-8400-d89bc373f6a6	0000	van	30	Active	2e0ee331-6173-41cc-a1ba-cc21c55e11b6
a25f8054-f899-48a8-844c-a7ad1744e7a0	063df397-2605-458d-8400-d89bc373f6a6	8099	bus	200	Active	2e0ee331-6173-41cc-a1ba-cc21c55e11b6
8611d51d-9010-4850-9728-eef46602b55e	53bbafdf-af00-464c-ba1c-ef364c4c5334	234gfdg	bus	567	Active	f9ec6287-6afa-4136-a59a-70bbc5a69d22
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             4185.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4186.dat                                                                                            0000600 0004000 0002000 00000001053 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        f3293150-984e-4ac4-94eb-549e1f2af609	DWPS Ajmer School	dwps_ajmer	5	t	sz.hasan@ibirdsservices.com\n	sz.hasan@ibirdsservices.com\n	https://caretest.indicrm.io/logos/ibs_sarvo/sidebarlogo.png	https://caretest.indicrm.io/logos/ibs_laksh/logo.png	Ajmer	pass me hi h	220033	Rajasthan	India
fb07e46e-832c-4d32-9989-9af9026b293e	Sankriti School	sankriti_ajmer	5	t	shivam@gmail.com	shivam.s@ibirdsservices.com	https://caretest.indicrm.io/logos/ibs_sarvo/sidebarlogo.png	https://caretest.indicrm.io/logos/ibs_laksh/logo.png	ajmer	check	342534	Rajasthan	India
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     4187.dat                                                                                            0000600 0004000 0002000 00000027152 14623575606 0014302 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        b06d0095-c74b-443c-b1d4-bfc0fcbf8b69	f3293150-984e-4ac4-94eb-549e1f2af609	74b5f156-c5cd-4e6a-82ee-fa7852edbcc7
86afb06f-e4ab-4273-b46d-e56c5b02dd6e	f3293150-984e-4ac4-94eb-549e1f2af609	81393f83-4adc-4834-9b76-0dcab464d1bf
9c191ab4-dbb9-4f9a-ae46-1f0f3a7a801c	f3293150-984e-4ac4-94eb-549e1f2af609	daf5385a-0ce2-4d54-a6a7-2e47d579f3f9
c5db0767-a209-4fc2-8b34-2ad411ec5094	f3293150-984e-4ac4-94eb-549e1f2af609	714e90c4-f95b-4243-916c-22a122bfeee4
cd99389a-8b95-4487-9ab7-c7b329bcdaa9	f3293150-984e-4ac4-94eb-549e1f2af609	64988ae0-66c1-4bd4-b50c-16a341e158e5
54a1efd2-892b-4c2f-a4bf-6776d7d100a0	f3293150-984e-4ac4-94eb-549e1f2af609	71115983-7384-4ad5-bb33-7ad4c12ae438
b411c35e-53b8-4444-af8f-783682234361	f3293150-984e-4ac4-94eb-549e1f2af609	80517365-c9a4-43d4-b906-0c6f708410e8
1315a701-264a-4405-8c85-3bee2aa9a67e	f3293150-984e-4ac4-94eb-549e1f2af609	df451422-483e-40a1-b953-ef6b7b6d9719
e98f01ba-61b9-4ac0-b219-1b2b7ec64438	f3293150-984e-4ac4-94eb-549e1f2af609	2b113e14-e83a-4692-90a5-b0875f586e98
429e270c-49e5-4896-9426-b52d8f15f7df	f3293150-984e-4ac4-94eb-549e1f2af609	d47b9fee-2bef-4494-ba41-932fbc685d47
8347d0ee-5493-4fdc-9732-ecb41d7cb373	f3293150-984e-4ac4-94eb-549e1f2af609	d384502e-c746-4ae0-a210-383fe2d66277
d7f1b5c1-ce9f-4e77-b001-a378f0797ac5	f3293150-984e-4ac4-94eb-549e1f2af609	2b15b844-81a3-4bea-8667-48d38eab1c26
5909b0f9-b214-4a35-96f1-74c7972955b5	f3293150-984e-4ac4-94eb-549e1f2af609	7385854a-2ce5-47fb-ac2d-4bb2a9c45406
20dd1ef8-7790-4272-bf9b-384072932b9e	f3293150-984e-4ac4-94eb-549e1f2af609	3f599cc4-62f9-4828-98af-440a52b3850a
5bcb0c41-581f-41bb-af72-e3fcab26e7b3	f3293150-984e-4ac4-94eb-549e1f2af609	451b60d2-09ef-4e71-b24e-c628c473fe10
276c09c8-7f66-4426-ac2d-46e896068415	f3293150-984e-4ac4-94eb-549e1f2af609	2cc25f59-576f-4c20-a517-e47c9e391b82
3e22e4f7-8c03-4c85-926f-48b45af8550a	f3293150-984e-4ac4-94eb-549e1f2af609	b3bb6f48-0553-4aea-bfde-bbaa924ea122
32329b04-9352-4712-a708-6596d662e05e	f3293150-984e-4ac4-94eb-549e1f2af609	60f6f906-44dd-4b46-825e-70f01c398be8
bbf529da-2c0a-4326-8a8a-f49aa1a26d12	f3293150-984e-4ac4-94eb-549e1f2af609	23a6d0eb-e168-4d32-bcd9-074e6bbed510
94e9ebe2-24f8-4979-af59-b6523a2ca47c	f3293150-984e-4ac4-94eb-549e1f2af609	065cd073-ef23-47e2-8c0a-01c3b25831f0
f5d7681e-d3f4-4c14-9fb6-aa84128915db	f3293150-984e-4ac4-94eb-549e1f2af609	6c2a7260-609d-44c6-ae8a-364f68938999
2a69f610-8af7-466b-88cc-3ba27940e11d	f3293150-984e-4ac4-94eb-549e1f2af609	4976f9a5-03fd-4f57-8f05-addbd365a0c3
a86e4480-b61f-4805-91d0-76deee4c5cae	f3293150-984e-4ac4-94eb-549e1f2af609	36e35849-7307-4891-a379-08380b613057
063e5c3c-7143-4bab-864a-860a58bc1f84	f3293150-984e-4ac4-94eb-549e1f2af609	cf69ab76-0145-4808-b2bf-c705406e20ab
5f5fede5-b923-461d-b879-e4ad4544086a	f3293150-984e-4ac4-94eb-549e1f2af609	0ff224ff-893b-438b-81cd-ca21a8256e30
a669ad41-6465-4d0f-b1c4-ad8198c71a45	f3293150-984e-4ac4-94eb-549e1f2af609	1e387e6f-7401-4283-9de6-a05dfc989951
2f4e9e49-1cbc-4586-b724-2cab8db0d3ef	f3293150-984e-4ac4-94eb-549e1f2af609	2109683e-703d-4e1a-87cf-d9dadea9b070
4cbb704a-96fb-4163-be09-9e91a5c5e15e	f3293150-984e-4ac4-94eb-549e1f2af609	29efc653-c198-41aa-8123-a259a89517ce
a3f2274d-0aac-4507-9c9d-3d0eb3553d35	f3293150-984e-4ac4-94eb-549e1f2af609	373bb2a7-910d-4e59-a009-a66764c0b605
5108b97b-1899-43cb-8f48-ebc504c533c8	f3293150-984e-4ac4-94eb-549e1f2af609	4a15b538-91ea-49fa-90a5-f470ede07d23
26f25e37-c889-4447-b43b-5a459be7bed4	f3293150-984e-4ac4-94eb-549e1f2af609	4c9fdab4-5dc3-46a7-b739-059d82e4228f
15efbb0e-ec68-4a79-8847-b4107e8964a3	f3293150-984e-4ac4-94eb-549e1f2af609	c480f1f7-0b72-4ffe-a2a4-1933c4932294
355d7b78-9f2c-4b67-ad89-d2849b0e7a12	f3293150-984e-4ac4-94eb-549e1f2af609	f4023b9e-61dc-4c38-827f-f547b4a5980e
ac960ea0-3502-4179-a10f-1f8c156917aa	f3293150-984e-4ac4-94eb-549e1f2af609	425e9802-c020-4f22-9fee-e49814062860
8cc3568f-45dc-4b81-a310-46c6c57e0e61	f3293150-984e-4ac4-94eb-549e1f2af609	32f8b4b4-45b9-43ac-9e1f-730a5d6a498c
cdae0752-4e46-41aa-9621-1dec77cb25e8	f3293150-984e-4ac4-94eb-549e1f2af609	ec145be4-a882-4b42-8215-8dbaa4a8be09
01f3e733-9ff9-4371-af12-43d9dc2bed29	f3293150-984e-4ac4-94eb-549e1f2af609	7866b338-98eb-48e9-9f09-c7f875dbbfea
d3eb9363-7a09-4259-a9df-a828e5df6b60	f3293150-984e-4ac4-94eb-549e1f2af609	59ba7920-cecf-40eb-bd68-6158422a1838
32b0f6cb-f4a3-48b2-945e-38f40f793d17	f3293150-984e-4ac4-94eb-549e1f2af609	6ed66890-1d83-4ef3-a4fc-77d9ecf9002b
035978d8-e633-406d-a6bf-8fff7dc19ebe	f3293150-984e-4ac4-94eb-549e1f2af609	cd8ce672-c7cb-4e76-923d-d017557c494f
db0fc6cc-ed03-4cad-9951-b5a6fa00c2b4	f3293150-984e-4ac4-94eb-549e1f2af609	54d232fe-08c5-435f-8c75-3bd58eab12b7
829832d7-2679-4828-85bd-f268ce73f63a	f3293150-984e-4ac4-94eb-549e1f2af609	99da87c1-3572-4338-bf77-e530919f3d53
4f29ee98-b9ea-4916-865a-ddb679405bba	f3293150-984e-4ac4-94eb-549e1f2af609	a2d8e03d-748b-4868-adea-1a8d0e534003
112e20ba-4753-4e9d-8439-3c60258589f6	f3293150-984e-4ac4-94eb-549e1f2af609	fb271adb-7b8c-48b8-bda9-141f26ef586a
491a861c-8357-4059-87c8-0c865b03cf8a	f3293150-984e-4ac4-94eb-549e1f2af609	5cff2e1a-0a0e-45b0-a0c6-9cff29c11046
e1626f3d-3011-46cd-ad62-06470d8f4130	f3293150-984e-4ac4-94eb-549e1f2af609	0c512185-0850-42bc-acb1-a49004e1799a
225e65e2-8c0c-4c4d-8954-690d649a63b6	f3293150-984e-4ac4-94eb-549e1f2af609	beae6908-20f0-40ee-aa1a-581569a2c83e
a2d6025c-8f07-40f3-bf56-85c88e5a6f2e	f3293150-984e-4ac4-94eb-549e1f2af609	bdcf2041-f55a-4433-aec1-d7bc627ade2e
8261369d-8f5c-48d1-8289-1285dddaef9d	f3293150-984e-4ac4-94eb-549e1f2af609	8a8e8212-c2fc-49c5-bc88-cd016924b3a9
1b0e2365-95ed-4462-834f-3d78124925f4	f3293150-984e-4ac4-94eb-549e1f2af609	2f99260e-b8d9-490b-8c7c-72e827daf8a6
ff3c993c-feeb-485b-b974-b6fa086c8035	f3293150-984e-4ac4-94eb-549e1f2af609	beb038b3-0e8c-4814-9b50-5be47cb59a78
fd5f86a0-3143-4bc6-81d8-6a07bcaf9fee	f3293150-984e-4ac4-94eb-549e1f2af609	810a8556-3e61-4b02-97db-dc92f175a3ed
ac4267c3-7737-47d9-8393-8424cdf6480d	f3293150-984e-4ac4-94eb-549e1f2af609	6a97f3fb-15d2-4bb3-92f6-0da9427e5807
167d8730-5e29-4acd-b656-9cda9f350f5d	f3293150-984e-4ac4-94eb-549e1f2af609	946bf7c9-f0d2-4544-af46-26916007069a
a8548497-4973-4656-a41a-990f2873df0d	f3293150-984e-4ac4-94eb-549e1f2af609	e6af9764-ef24-4034-82d9-28542275a165
7b9cc1bc-a3f7-4699-9a61-37b8cb48e175	f3293150-984e-4ac4-94eb-549e1f2af609	065da906-322f-4ba2-9357-6a1b766c3b00
99ea2551-4c67-471c-93a2-eb4b6fb53041	f3293150-984e-4ac4-94eb-549e1f2af609	34e3924a-aeae-4b6b-b202-33415b697477
61ebf555-55ad-44e0-a772-40678304cca7	f3293150-984e-4ac4-94eb-549e1f2af609	823df327-26a2-463b-90bd-80cb695897fa
7faa1b79-7264-4e39-8024-0bd6aa1f4050	f3293150-984e-4ac4-94eb-549e1f2af609	46c898c8-eb75-433a-8a3e-cf183f598900
5ff86dba-33bc-490e-a61f-bae0ff28472a	fb07e46e-832c-4d32-9989-9af9026b293e	74b5f156-c5cd-4e6a-82ee-fa7852edbcc7
926aa553-2783-4225-8e10-ed15d8171c4a	fb07e46e-832c-4d32-9989-9af9026b293e	81393f83-4adc-4834-9b76-0dcab464d1bf
b090f1e4-3d44-4af4-bec4-a69a3aa0b807	fb07e46e-832c-4d32-9989-9af9026b293e	daf5385a-0ce2-4d54-a6a7-2e47d579f3f9
45e3a3ad-111f-420a-b3b3-51008bbdea4a	fb07e46e-832c-4d32-9989-9af9026b293e	714e90c4-f95b-4243-916c-22a122bfeee4
5240d1ec-947e-4089-9197-0b1b63374378	fb07e46e-832c-4d32-9989-9af9026b293e	64988ae0-66c1-4bd4-b50c-16a341e158e5
ad562fdb-ac8a-4895-a3e9-c70a0bd1fdfd	fb07e46e-832c-4d32-9989-9af9026b293e	71115983-7384-4ad5-bb33-7ad4c12ae438
6752c580-07b1-4709-af08-d4b797e88bfa	fb07e46e-832c-4d32-9989-9af9026b293e	80517365-c9a4-43d4-b906-0c6f708410e8
3adf0814-0f94-4e2d-8a88-ecb1275f7d37	fb07e46e-832c-4d32-9989-9af9026b293e	df451422-483e-40a1-b953-ef6b7b6d9719
90851752-840e-427f-bc04-b34cf82c2f09	fb07e46e-832c-4d32-9989-9af9026b293e	2b113e14-e83a-4692-90a5-b0875f586e98
30170aaa-8d1c-41e8-9e9d-af341a645ded	fb07e46e-832c-4d32-9989-9af9026b293e	d47b9fee-2bef-4494-ba41-932fbc685d47
09e9573d-c78f-4503-8e4d-93c8aca43dea	fb07e46e-832c-4d32-9989-9af9026b293e	d384502e-c746-4ae0-a210-383fe2d66277
199ceed8-39fc-4555-980d-d5c447d5651e	fb07e46e-832c-4d32-9989-9af9026b293e	2b15b844-81a3-4bea-8667-48d38eab1c26
2f81a6ab-e143-483f-9cbd-417c729fa6c5	fb07e46e-832c-4d32-9989-9af9026b293e	7385854a-2ce5-47fb-ac2d-4bb2a9c45406
a6ed561d-3ff4-4262-9e3b-1b1874aa7178	fb07e46e-832c-4d32-9989-9af9026b293e	3f599cc4-62f9-4828-98af-440a52b3850a
c80f3eec-5811-4001-baab-6952549098c2	fb07e46e-832c-4d32-9989-9af9026b293e	451b60d2-09ef-4e71-b24e-c628c473fe10
7fb1cacd-b909-4cee-814b-fb580d598757	fb07e46e-832c-4d32-9989-9af9026b293e	2cc25f59-576f-4c20-a517-e47c9e391b82
dea2ed8f-f73f-4e84-8011-5bbb0aed6d56	fb07e46e-832c-4d32-9989-9af9026b293e	b3bb6f48-0553-4aea-bfde-bbaa924ea122
90122ec1-9a88-4858-ad02-da6f23c376f1	fb07e46e-832c-4d32-9989-9af9026b293e	60f6f906-44dd-4b46-825e-70f01c398be8
58703545-5f44-49cd-bb01-6ef8e1bb2fff	fb07e46e-832c-4d32-9989-9af9026b293e	23a6d0eb-e168-4d32-bcd9-074e6bbed510
35c4a272-5ed1-434f-b44f-181e4badbbb3	fb07e46e-832c-4d32-9989-9af9026b293e	065cd073-ef23-47e2-8c0a-01c3b25831f0
0ad5728c-8af2-467e-909d-1cfb21a13e9f	fb07e46e-832c-4d32-9989-9af9026b293e	6c2a7260-609d-44c6-ae8a-364f68938999
c38b9a59-9ad6-42ca-8f61-56dbd3086824	fb07e46e-832c-4d32-9989-9af9026b293e	4976f9a5-03fd-4f57-8f05-addbd365a0c3
40ad0b2f-4d61-47df-acb3-677d8992b8fe	fb07e46e-832c-4d32-9989-9af9026b293e	36e35849-7307-4891-a379-08380b613057
266fba1b-7cb6-45bd-9dec-1e9248714c03	fb07e46e-832c-4d32-9989-9af9026b293e	cf69ab76-0145-4808-b2bf-c705406e20ab
b332b1ef-cc76-4435-a82b-b6621cad9379	fb07e46e-832c-4d32-9989-9af9026b293e	0ff224ff-893b-438b-81cd-ca21a8256e30
9890737c-813b-4be9-b0ab-e6f85aeb07be	fb07e46e-832c-4d32-9989-9af9026b293e	1e387e6f-7401-4283-9de6-a05dfc989951
67d9aaf1-43be-414e-b3bb-aa69e790c2c5	fb07e46e-832c-4d32-9989-9af9026b293e	2109683e-703d-4e1a-87cf-d9dadea9b070
f229bc5e-e807-41c9-95fd-242c4b58bf45	fb07e46e-832c-4d32-9989-9af9026b293e	29efc653-c198-41aa-8123-a259a89517ce
9c91ea07-6c1b-412a-95ba-f49fc9f521ce	fb07e46e-832c-4d32-9989-9af9026b293e	373bb2a7-910d-4e59-a009-a66764c0b605
31ec3430-2c01-4915-8aaf-4164e01d16f1	fb07e46e-832c-4d32-9989-9af9026b293e	4a15b538-91ea-49fa-90a5-f470ede07d23
b90c7910-78ca-4293-9fcb-71561f6af09d	fb07e46e-832c-4d32-9989-9af9026b293e	4c9fdab4-5dc3-46a7-b739-059d82e4228f
ecae11bc-b35c-4f74-896b-a19374a05eff	fb07e46e-832c-4d32-9989-9af9026b293e	c480f1f7-0b72-4ffe-a2a4-1933c4932294
5d3258e6-e386-4372-8151-5b326bbc71f3	fb07e46e-832c-4d32-9989-9af9026b293e	f4023b9e-61dc-4c38-827f-f547b4a5980e
f51e6891-7ae2-4cb6-93e3-37adfed32a62	fb07e46e-832c-4d32-9989-9af9026b293e	425e9802-c020-4f22-9fee-e49814062860
c6645e8e-a1ec-4f52-8792-77ec0141bc29	fb07e46e-832c-4d32-9989-9af9026b293e	32f8b4b4-45b9-43ac-9e1f-730a5d6a498c
7bb16a77-1dac-4e73-9264-43a8c2db88a7	fb07e46e-832c-4d32-9989-9af9026b293e	ec145be4-a882-4b42-8215-8dbaa4a8be09
326ae7f0-dbae-405f-86f5-95394c857af0	fb07e46e-832c-4d32-9989-9af9026b293e	7866b338-98eb-48e9-9f09-c7f875dbbfea
4b530fb2-dc99-4d70-8ac6-d9124a8052f1	fb07e46e-832c-4d32-9989-9af9026b293e	59ba7920-cecf-40eb-bd68-6158422a1838
b8adbd4f-4abd-4598-84f2-5fe811d89fa9	fb07e46e-832c-4d32-9989-9af9026b293e	6ed66890-1d83-4ef3-a4fc-77d9ecf9002b
e30f08de-08fa-4c7d-b5da-1bb38645419a	fb07e46e-832c-4d32-9989-9af9026b293e	cd8ce672-c7cb-4e76-923d-d017557c494f
32db4a23-c636-4f93-9d1a-4e30ba68a23f	fb07e46e-832c-4d32-9989-9af9026b293e	54d232fe-08c5-435f-8c75-3bd58eab12b7
6f6ac0e8-1836-40ae-9d5f-d0bf67d6280e	fb07e46e-832c-4d32-9989-9af9026b293e	99da87c1-3572-4338-bf77-e530919f3d53
d36efadf-fdc5-47fe-9f88-b38be11a6536	fb07e46e-832c-4d32-9989-9af9026b293e	a2d8e03d-748b-4868-adea-1a8d0e534003
ddc991d8-5cb1-49dd-803b-c5a2968d3525	fb07e46e-832c-4d32-9989-9af9026b293e	fb271adb-7b8c-48b8-bda9-141f26ef586a
1620914d-6d52-409c-96fd-98ebf6fccdbf	fb07e46e-832c-4d32-9989-9af9026b293e	5cff2e1a-0a0e-45b0-a0c6-9cff29c11046
350f8667-682c-41d4-81b8-6d50034f951b	f3293150-984e-4ac4-94eb-549e1f2af609	6405ccf4-93cc-46e2-8102-fb306e22bbd6
9f5375ba-2041-4b2a-8f70-55f3128f6b25	f3293150-984e-4ac4-94eb-549e1f2af609	db535885-a673-4330-b52d-e78207e2c621
8a021623-f9b7-4f9a-9424-f02a123db205	f3293150-984e-4ac4-94eb-549e1f2af609	dbf6ce40-28bc-4e7e-9385-9319d34071f4
\.


                                                                                                                                                                                                                                                                                                                                                                                                                      4188.dat                                                                                            0000600 0004000 0002000 00000020457 14623575606 0014304 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        74b5f156-c5cd-4e6a-82ee-fa7852edbcc7	Role List	Active	role_list_p	fa-solid fa-chart-simple mx-2	/rolelist	className	0ff224ff-893b-438b-81cd-ca21a8256e30	\N
81393f83-4adc-4834-9b76-0dcab464d1bf	Role Permission List	Active	role_permission_list_p	fa-solid fa-chart-simple mx-2	/rolepermissionlist	className	0ff224ff-893b-438b-81cd-ca21a8256e30	\N
daf5385a-0ce2-4d54-a6a7-2e47d579f3f9	Syllabus List	Active	syllabus_list_s	fa-solid fa-chart-simple mx-2	/syllabuslist	className	2109683e-703d-4e1a-87cf-d9dadea9b070	\N
714e90c4-f95b-4243-916c-22a122bfeee4	Students Enquiry List	Active	student_enquiry_list_s	fa-solid fas fa-street-view mx-2	/students	className	71115983-7384-4ad5-bb33-7ad4c12ae438	\N
64988ae0-66c1-4bd4-b50c-16a341e158e5	Students Registration List	Active	student_admission_sd	fa-solid fas fa-chart-line mx-2	/studentaddmissions	className	71115983-7384-4ad5-bb33-7ad4c12ae438	\N
80517365-c9a4-43d4-b906-0c6f708410e8	Subject	Active	subject_s	fa-solid fa-bars mx-2		className	\N	8
df451422-483e-40a1-b953-ef6b7b6d9719	RTE	Active	rte_r	fa fa-graduation-cap mx-2	\N	className	\N	4
2b113e14-e83a-4692-90a5-b0875f586e98	Home	Active	Home__h	fa-solid fa-house mx-2	/	className	\N	1
d47b9fee-2bef-4494-ba41-932fbc685d47	Section	Active	section_s	fas fa-puzzle-piece mx-2		className	\N	7
d384502e-c746-4ae0-a210-383fe2d66277	Employee	Active	employee__e	fa-solid fa-user-tie mx-2	/staffs	className	\N	10
2b15b844-81a3-4bea-8667-48d38eab1c26	Class List	Active	class_list__c	fa-solid fa-landmark-magnifying-glass	/classes	className	373bb2a7-910d-4e59-a009-a66764c0b605	\N
7385854a-2ce5-47fb-ac2d-4bb2a9c45406	Employee List	Active	employee_list__e	fa-solid fa-users mx-2	/staffs	className	d384502e-c746-4ae0-a210-383fe2d66277	\N
3f599cc4-62f9-4828-98af-440a52b3850a	Transport	Active	transport__t	fa-solid fa-bus mx-2	\N	className	\N	11
451b60d2-09ef-4e71-b24e-c628c473fe10	Register Driver	Active	register_driver__r	fa-regular fa-hard-drive mx-2	/driver/e	className	3f599cc4-62f9-4828-98af-440a52b3850a	\N
2cc25f59-576f-4c20-a517-e47c9e391b82	Location List	Active	location_list__l	fa-solid fa-location-crosshairs mx-2	/transportation/locationlist	className	3f599cc4-62f9-4828-98af-440a52b3850a	\N
b3bb6f48-0553-4aea-bfde-bbaa924ea122	Fare List	Active	fare_list__f	fa-solid fa-indian-rupee-sign mx-2	/transportation/farelist	className	3f599cc4-62f9-4828-98af-440a52b3850a	\N
60f6f906-44dd-4b46-825e-70f01c398be8	Route List	Active	route_list__r	fa-solid fa-route mx-2	/transportation/routelist	className	3f599cc4-62f9-4828-98af-440a52b3850a	\N
23a6d0eb-e168-4d32-bcd9-074e6bbed510	Vehicle List	Active	vehicle_list__v	fa-solid fa-bus mx-2	/transportation/vehicles	className	3f599cc4-62f9-4828-98af-440a52b3850a	\N
065cd073-ef23-47e2-8c0a-01c3b25831f0	Fee	Active	fee__f	fa fa-money mx-2	\N	className	\N	12
6c2a7260-609d-44c6-ae8a-364f68938999	Fee Head Master List	Active	fee_head_master_list__f	fa-solid fa-comment-dollar mx-2	/feesheadmasterlist	className	065cd073-ef23-47e2-8c0a-01c3b25831f0	\N
4976f9a5-03fd-4f57-8f05-addbd365a0c3	Fee Master List	Active	fee_master_list__f	fa-solid fa-dollar-sign mx-2	/feesmasterlist	className	065cd073-ef23-47e2-8c0a-01c3b25831f0	\N
36e35849-7307-4891-a379-08380b613057	Fee Deposit	Active	fee_deposit__f	fa-solid fa-money-bill-transfer mx-2	/feedeposite	className	065cd073-ef23-47e2-8c0a-01c3b25831f0	\N
cf69ab76-0145-4808-b2bf-c705406e20ab	Fee Discount Master	Active	fee_discount__f	fa-solid fa-money-bill-transfer mx-2	/feesdiscount	className	065cd073-ef23-47e2-8c0a-01c3b25831f0	\N
0ff224ff-893b-438b-81cd-ca21a8256e30	Permission	Active	permission__p	fa fa-chain mx-2	\N	className	\N	2
1e387e6f-7401-4283-9de6-a05dfc989951	RTE Student List	Active	rte_student_list__r	fa-solid fa-chart-simple mx-2	/rte	className	df451422-483e-40a1-b953-ef6b7b6d9719	\N
2109683e-703d-4e1a-87cf-d9dadea9b070	Syllabus	Active	syllabus__s	fa fa-list mx-2	\N	className	\N	5
29efc653-c198-41aa-8123-a259a89517ce	Subject List	Active	Subject_list__s	fa-solid fa-chart-simple mx-2	/subjects	className	80517365-c9a4-43d4-b906-0c6f708410e8	\N
373bb2a7-910d-4e59-a009-a66764c0b605	Class	Active	class__c	fas fa-th-list mx-2		className	\N	6
4a15b538-91ea-49fa-90a5-f470ede07d23	Assign Subject Class	Active	Assign_subject_class__s	fa-solid fa-chart-simple mx-2	/assignsubjectclass	className	80517365-c9a4-43d4-b906-0c6f708410e8	\N
4c9fdab4-5dc3-46a7-b739-059d82e4228f	Section List	Active	Section_List__s		/section	className	d47b9fee-2bef-4494-ba41-932fbc685d47	\N
c480f1f7-0b72-4ffe-a2a4-1933c4932294	Time Table	Active	time_table__t	fa fa-calendar mx-2	\N	className	\N	13
f4023b9e-61dc-4c38-827f-f547b4a5980e	Time Slot	Active	time_slot__t	fa-solid fas fa-street-view mx-2	/timeslot	className	c480f1f7-0b72-4ffe-a2a4-1933c4932294	\N
425e9802-c020-4f22-9fee-e49814062860	Class Wise Time Table	Active	class_wise_time_table__c	fa-solid fas fa-chart-line mx-2	/classtimetable	className	c480f1f7-0b72-4ffe-a2a4-1933c4932294	\N
32f8b4b4-45b9-43ac-9e1f-730a5d6a498c	Print Time Table	Active	print_time_table__p	fa-solid fas fa-chart-line mx-2	/printtimetable	className	c480f1f7-0b72-4ffe-a2a4-1933c4932294	\N
ec145be4-a882-4b42-8215-8dbaa4a8be09	Module List	Active	module_list_p	fa-solid fa-chart-simple mx-2	/modulelist	className	0ff224ff-893b-438b-81cd-ca21a8256e30	\N
7866b338-98eb-48e9-9f09-c7f875dbbfea	Exam	Active	exam__e	fa fa-graduation-cap mx-2	\N	className	\N	9
59ba7920-cecf-40eb-bd68-6158422a1838	Quick Launcher	Active	quick_launcher__q	fa-solid fa-jet-fighter mx-2	/quick-launcher	className	\N	20
6ed66890-1d83-4ef3-a4fc-77d9ecf9002b	Attendance Master	Active	attendance_master__a	\N	/Attendance_master	\N	54d232fe-08c5-435f-8c75-3bd58eab12b7	\N
cd8ce672-c7cb-4e76-923d-d017557c494f	Attendance List	Active	attendance_list__a	\N	/list_attendance	\N	54d232fe-08c5-435f-8c75-3bd58eab12b7	\N
54d232fe-08c5-435f-8c75-3bd58eab12b7	Attendance	Active	attendance__a	fa-solid fa-users mx-2	\N	\N	\N	14
99da87c1-3572-4338-bf77-e530919f3d53	Exam List	Active	exam_list__e	\N	/examlist	\N	7866b338-98eb-48e9-9f09-c7f875dbbfea	\N
a2d8e03d-748b-4868-adea-1a8d0e534003	Exam Schedule	Active	exam_schedule__e	\N	/examschedule	\N	7866b338-98eb-48e9-9f09-c7f875dbbfea	\N
fb271adb-7b8c-48b8-bda9-141f26ef586a	Add Events	Active	add_events__a	\N	/addevent	\N	0c512185-0850-42bc-acb1-a49004e1799a	\N
5cff2e1a-0a0e-45b0-a0c6-9cff29c11046	Events Calendar	Active	events_calendar__e	\N	/eventscalender	\N	0c512185-0850-42bc-acb1-a49004e1799a	\N
0c512185-0850-42bc-acb1-a49004e1799a	Event	Active	event__e	fas fa-calendar mx-2	\N	className	\N	16
beae6908-20f0-40ee-aa1a-581569a2c83e	Home Work	Active	home_work__h	fas fa-book mx-2	\N	className	\N	15
bdcf2041-f55a-4433-aec1-d7bc627ade2e	Assignment List	Active	assignment_list__a	\N	/assignmentlist	\N	beae6908-20f0-40ee-aa1a-581569a2c83e	\N
8a8e8212-c2fc-49c5-bc88-cd016924b3a9	Library	Active	library__l	fa fa-book mx-2	\N	className	\N	17
2f99260e-b8d9-490b-8c7c-72e827daf8a6	Book List	Active	book_list__c	bi bi-book-half mx-2	/books	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
beb038b3-0e8c-4814-9b50-5be47cb59a78	Issue Book	Active	issue_book_list__c	bi bi-book-fill mx-2	/issue_book	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
810a8556-3e61-4b02-97db-dc92f175a3ed	Purchase List	Active	purchase_list__c	fa-solid fa-clone mx-2	/purchase	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
6a97f3fb-15d2-4bb3-92f6-0da9427e5807	Language List	Active	language_list__c	fa fa-language mx-2	/language	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
946bf7c9-f0d2-4544-af46-26916007069a	Category List	Active	category_list__c	fa-solid fa-list mx-2	/category	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
e6af9764-ef24-4034-82d9-28542275a165	Author LIst	Active	author_list__c	fa-solid fa-pen-to-square mx-2	/author	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
065da906-322f-4ba2-9357-6a1b766c3b00	Supplier List	Active	supplier_list__c	fa-solid fa-truck-fast mx-2	/supplier	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
34e3924a-aeae-4b6b-b202-33415b697477	Publisher List	Active	publisher_list__c	fa-solid fa-cart-shopping mx-2	/publisher	className	8a8e8212-c2fc-49c5-bc88-cd016924b3a9	\N
823df327-26a2-463b-90bd-80cb695897fa	Session	Active	Session	fas fa-book mx-2		className	\N	8
46c898c8-eb75-433a-8a3e-cf183f598900	session list	Active	session_list	fas fa-book mx-2	/sessionlist	className	823df327-26a2-463b-90bd-80cb695897fa	\N
71115983-7384-4ad5-bb33-7ad4c12ae438	Student Management	Active	student_management_s	fa fa-graduation-cap mx-2		className	\N	3
\.


                                                                                                                                                                                                                 4189.dat                                                                                            0000600 0004000 0002000 00000001162 14623575606 0014275 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2f000d71-0bc1-462a-8561-0ee1e883ae69	EDIT_LEAD	Active
7914e8c8-8656-4bdd-b3be-bdfee5467054	MODIFY_ALL	Active
97bc110a-7bf4-48a3-8ed1-7017aa94b617	VIEW_ALL	Active
4ac8de0a-cc82-4452-8e1b-a4154429dee8	VIEW_LEAD	Active
90e75d58-c222-408e-8927-15a1942a2ff3	DELETE_LEAD	Active
8a791be7-73bc-43c5-96bb-a089adc21f12	VIEW_PRODUCT	Active
64278a1c-c992-434e-b0c7-05fcc38b1010	EDIT_PRODUCT	Active
a98fb898-19c5-49d2-9041-b1c828ebedae	DELETE_PRODUCT	Active
7226df8c-9abc-4f20-a549-506d78725bc9	VIEW_PROPERTY	Active
86c965ed-3064-4767-ac54-1bab90c69f12	EDIT_PROPERTY	Active
d7231c5e-675b-4cc7-94a4-051f076fd0de	DELETE_PROPERTY	Active
\.


                                                                                                                                                                                                                                                                                                                                                                                                              4190.dat                                                                                            0000600 0004000 0002000 00000000412 14623575606 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        04c86856-2acf-4144-84ac-bfe27851999a	ADMIN	For Client Admin	Active
d198a50e-e3a9-423b-b49f-d10030ccb178	SYS_ADMIN	For iBirds Use Only	Active
f6760118-672e-472b-b022-171894319179	USER	For General User	Active
8d2b4188-c0a3-4d1c-98af-c24b7f9ae1ab	PARENT	\N	Active
\.


                                                                                                                                                                                                                                                      4191.dat                                                                                            0000600 0004000 0002000 00000001336 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        436cb4be-88b6-4cfe-bcab-5ac871bb77f7	2f000d71-0bc1-462a-8561-0ee1e883ae69	d198a50e-e3a9-423b-b49f-d10030ccb178	System Admin Syllabus Edit Lead	3ac63821-74ab-428f-a162-38730f4d7378	t	t	t	Active	t	t	t
9d294199-97ee-428f-8634-79688ec76844	7914e8c8-8656-4bdd-b3be-bdfee5467054	d198a50e-e3a9-423b-b49f-d10030ccb178	System Admin Syllabus Modify All	3ac63821-74ab-428f-a162-38730f4d7378	t	t	t	Active	t	t	t
6d278190-43f3-4390-8a73-9ca1ffad3478	97bc110a-7bf4-48a3-8ed1-7017aa94b617	d198a50e-e3a9-423b-b49f-d10030ccb178	System Admin Syllabus View All	3ac63821-74ab-428f-a162-38730f4d7378	t	t	t	Active	t	t	t
f58be498-892c-49f2-a7ae-a66fef12bcc3	\N	04c86856-2acf-4144-84ac-bfe27851999a	\N	2b113e14-e83a-4692-90a5-b0875f586e98	t	f	f	\N	f	f	t
\.


                                                                                                                                                                                                                                                                                                  4192.dat                                                                                            0000600 0004000 0002000 00000001605 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        d7c04d66-7773-44c3-844c-eb2353dbcd88	Aslam	Bari	$2a$10$Q2Wb8k2HIyQtLfVXqUgXQu1KG2x9GxK7smYBVpocQlon8aVGHDvTS	aslam.bari@gmail.com	\N	\N	\N
aa9b49eb-bffb-406b-90a9-e9eb84f033ce	Najab	khan	$2a$10$tN9bmOhCK8IO89eUSqat7eAOeSwn5BoNPp/TePGKDXTaSAgTUPBN.	najab@gmail.com	\N	\N	\N
e7fbab63-7730-4ec9-be73-a62e33ea73c3	Farhan	Khan	Admin@1234	farhankhancroft@gmail.com	\N	\N	\N
d7122a87-fba5-4fcc-9bdd-362e052c54e5	Girisha	Hemnani	$2a$10$vBG9tUmIGi4Sjn3QJ//EyuOAYrInrz3p3/tXQhD31fNbyRLzjBXVa	girisha@gmail.com	f3293150-984e-4ac4-94eb-549e1f2af609	\N	\N
cd1ebbed-e3c5-4da8-8eff-4369112571f3	Zakir	Hasan	$2a$10$8.dtM8v9FqTWapwryurPhe1GhdU3xqB1LaPyzxOICywE14sHdUV3a	zakir@gmail.com	f3293150-984e-4ac4-94eb-549e1f2af609	ADMIN	\N
bd35c9c1-6a0c-4d81-badc-00726fa9237f	Prince	Parmar	$2a$10$8.dtM8v9FqTWapwryurPhe1GhdU3xqB1LaPyzxOICywE14sHdUV3a	prince@gmail.com	fb07e46e-832c-4d32-9989-9af9026b293e	SUPER_ADMIN	\N
\.


                                                                                                                           4193.dat                                                                                            0000600 0004000 0002000 00000001237 14623575606 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        758548c6-ef24-4afd-9a21-3a397fec0a51	ac720705-0cbb-4a11-9274-b1e02a5aca35	add7702d-5ee0-4f50-80c2-4a24065a6867
7bc765dd-a89f-4c19-bd3a-d8ee4681214e	06bec968-d91c-4cd9-a236-9c59930a5893	c09d19b6-57f0-4d7e-bf24-18b556c3ddd7
229181a8-92b3-4549-91d1-84e69dbfa143	579b7faf-7ca7-4d95-ad93-edcfd11291d4	301a2779-73b0-45c4-902e-3acb9c932796
b45fe015-488b-4a7b-8b0c-fcbe9eaafcfc	d7122a87-fba5-4fcc-9bdd-362e052c54e5	c09d19b6-57f0-4d7e-bf24-18b556c3ddd7
dba11497-be18-41a5-b425-0d3d0a01eab8	cd1ebbed-e3c5-4da8-8eff-4369112571f3	add7702d-5ee0-4f50-80c2-4a24065a6867
61f90162-e100-4f7e-9979-e1e9c24b00f9	cd1ebbed-e3c5-4da8-8eff-4369112571f3	d198a50e-e3a9-423b-b49f-d10030ccb178
\.


                                                                                                                                                                                                                                                                                                                                                                 4194.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4195.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014265 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4196.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4197.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4198.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014270 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4199.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014271 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4200.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014250 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4201.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014251 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4203.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014253 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4204.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4205.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4206.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4207.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4208.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4209.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4210.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014251 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4211.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014252 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4213.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4214.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4215.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4216.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4217.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4218.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4219.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4220.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014252 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4221.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014253 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4222.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4223.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4224.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4225.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4226.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4227.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4228.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4229.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4230.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014253 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4231.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014254 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4232.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014255 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4233.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4234.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           4235.dat                                                                                            0000600 0004000 0002000 00000000005 14623575606 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           restore.sql                                                                                         0000600 0004000 0002000 00000372366 14623575606 0015423 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE digital_school;
--
-- Name: digital_school; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE digital_school WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_India.1252';


ALTER DATABASE digital_school OWNER TO postgres;

\connect digital_school

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dwps_ajmer; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dwps_ajmer;


ALTER SCHEMA dwps_ajmer OWNER TO postgres;

--
-- Name: sankriti_ajmer; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sankriti_ajmer;


ALTER SCHEMA sankriti_ajmer OWNER TO postgres;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: recordtype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.recordtype AS ENUM (
    'Parent',
    'Student',
    'Staff',
    'Driver',
    'Teacher'
);


ALTER TYPE public.recordtype OWNER TO postgres;

--
-- Name: sync_lastmod(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_lastmod() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.lastmodifieddate := NOW();


  RETURN NEW;
END;
$$;


ALTER FUNCTION public.sync_lastmod() OWNER TO postgres;

--
-- Name: update_book_copies_on_issue(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_book_copies_on_issue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update issued count
    UPDATE dwps_ajmer.book b
    SET issued = (
        SELECT SUM(CASE WHEN i.status = 'Issued' THEN 1 ELSE 0 END)
        FROM dwps_ajmer.issue i
        WHERE i.book_id = b.id
    );


    -- Update missing count
    UPDATE dwps_ajmer.book b
    SET missing = (
        SELECT SUM(CASE WHEN i.status = 'Missing' THEN 1 ELSE 0 END)
        FROM dwps_ajmer.issue i
        WHERE i.book_id = b.id
    );


    RETURN NULL;
END;
$$;


ALTER FUNCTION public.update_book_copies_on_issue() OWNER TO postgres;

--
-- Name: update_book_copies_on_issue_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_book_copies_on_issue_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status = 'Issued' THEN
        UPDATE dwps_ajmer.book
        SET issued = COALESCE(issued, 0) + 1
        WHERE id = NEW.book_id;
		
    ELSIF NEW.status = 'Returned' THEN
        UPDATE dwps_ajmer.book
        SET issued = COALESCE(issued, 1) - 1
        WHERE id = NEW.book_id AND COALESCE(issued, 0) > 0;
		
    ELSIF NEW.status = 'Missing' THEN
        UPDATE dwps_ajmer.book
        SET missing = COALESCE(missing, 0) + 1,
            issued = COALESCE(issued, 0) - 1
        WHERE id = NEW.book_id AND COALESCE(issued, 0) > 0;
    END IF;


    IF OLD.status = 'Issued' OR OLD.status = 'Missing' THEN
        UPDATE dwps_ajmer.book
        SET issued = COALESCE(issued, 0) - 1
        WHERE id = OLD.book_id AND COALESCE(issued, 0) > 0;
    END IF;


    RETURN NULL;
END;
$$;


ALTER FUNCTION public.update_book_copies_on_issue_status() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assign_subject; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.assign_subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    createdbyid uuid,
    lastmodifiedbyid uuid
);


ALTER TABLE dwps_ajmer.assign_subject OWNER TO postgres;

--
-- Name: assign_transport; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.assign_transport (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_admission_id uuid,
    transport_id uuid,
    drop_location text,
    fare_id uuid,
    fare_amount numeric,
    distance numeric,
    route_direction text,
    sessionid uuid
);


ALTER TABLE dwps_ajmer.assign_transport OWNER TO postgres;

--
-- Name: assignment; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.assignment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    date date,
    title character varying(255) NOT NULL,
    description text,
    status character varying(50),
    session_id uuid
);


ALTER TABLE dwps_ajmer.assignment OWNER TO postgres;

--
-- Name: attendance; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    attendance_master_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    present character varying,
    absent character varying
);


ALTER TABLE dwps_ajmer.attendance OWNER TO postgres;

--
-- Name: attendance_line_item; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.attendance_line_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    attendance_id uuid,
    date date,
    status character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    data json
);


ALTER TABLE dwps_ajmer.attendance_line_item OWNER TO postgres;

--
-- Name: attendance_master; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.attendance_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    total_lectures character varying,
    type character varying,
    session_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month character varying,
    year character varying
);


ALTER TABLE dwps_ajmer.attendance_master OWNER TO postgres;

--
-- Name: author; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.author (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    status character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE dwps_ajmer.author OWNER TO postgres;

--
-- Name: book; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.book (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying,
    author_id uuid,
    isbn character varying,
    category_id uuid,
    publisher_id uuid,
    publish_date date,
    status character varying,
    language_id uuid,
    missing integer DEFAULT 0,
    issued integer DEFAULT 0,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE dwps_ajmer.book OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.category (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    description character varying
);


ALTER TABLE dwps_ajmer.category OWNER TO postgres;

--
-- Name: class; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.class (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    classname character varying NOT NULL,
    maxstrength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    aliasname character varying,
    status character varying,
    session_id uuid,
    session_year character varying
);


ALTER TABLE dwps_ajmer.class OWNER TO postgres;

--
-- Name: class_timing; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.class_timing (
    id integer NOT NULL,
    name character varying NOT NULL,
    isactive boolean NOT NULL,
    session_id integer NOT NULL,
    created_by uuid,
    modified_by uuid,
    created_date timestamp without time zone,
    modified_date timestamp without time zone
);


ALTER TABLE dwps_ajmer.class_timing OWNER TO postgres;

--
-- Name: class_timing_id_seq; Type: SEQUENCE; Schema: dwps_ajmer; Owner: postgres
--

CREATE SEQUENCE dwps_ajmer.class_timing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dwps_ajmer.class_timing_id_seq OWNER TO postgres;

--
-- Name: class_timing_id_seq; Type: SEQUENCE OWNED BY; Schema: dwps_ajmer; Owner: postgres
--

ALTER SEQUENCE dwps_ajmer.class_timing_id_seq OWNED BY dwps_ajmer.class_timing.id;


--
-- Name: contactsequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contactsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contactsequence OWNER TO postgres;

--
-- Name: contact; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.contact (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    salutation character varying,
    firstname character varying NOT NULL,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    profession character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    spousename character varying,
    qualification character varying,
    description character varying,
    parentid uuid,
    department character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contactno character varying DEFAULT ('CTC-'::text || nextval('public.contactsequence'::regclass)),
    religion character varying,
    lastname character varying,
    recordtype character varying
);


ALTER TABLE dwps_ajmer.contact OWNER TO postgres;

--
-- Name: receiptsequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.receiptsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receiptsequence OWNER TO postgres;

--
-- Name: deposit; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.deposit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    depositfee numeric,
    dateofdeposit timestamp without time zone DEFAULT now(),
    fromdate date,
    todate date,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    receiptno character varying DEFAULT ('R-'::text || lpad((nextval('public.receiptsequence'::regclass))::text, 4, '0'::text))
);


ALTER TABLE dwps_ajmer.deposit OWNER TO postgres;

--
-- Name: discount; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.discount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    percent numeric(5,2),
    sessionid uuid,
    fee_head_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    amount numeric,
    status text
);


ALTER TABLE dwps_ajmer.discount OWNER TO postgres;

--
-- Name: discount_line_items; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.discount_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    discountid uuid
);


ALTER TABLE dwps_ajmer.discount_line_items OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    event_type character varying(255) NOT NULL,
    start_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_date date NOT NULL,
    end_time time without time zone NOT NULL,
    description text,
    title character varying(255),
    colorcode character varying(255),
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid,
    status character varying
);


ALTER TABLE dwps_ajmer.events OWNER TO postgres;

--
-- Name: exam_schedule; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.exam_schedule (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_title_id uuid,
    schedule_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration numeric,
    room_no text,
    examinor_id uuid,
    status text,
    subject_id uuid,
    class_id uuid,
    max_marks integer,
    min_marks integer,
    ispractical boolean,
    sessionid uuid
);


ALTER TABLE dwps_ajmer.exam_schedule OWNER TO postgres;

--
-- Name: exam_title; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.exam_title (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    status text,
    sessionid uuid
);


ALTER TABLE dwps_ajmer.exam_title OWNER TO postgres;

--
-- Name: fare_master; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.fare_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fare numeric,
    fromdistance numeric,
    todistance numeric,
    status character varying
);


ALTER TABLE dwps_ajmer.fare_master OWNER TO postgres;

--
-- Name: fee_deposite; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.fee_deposite (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    amount numeric,
    payment_date date,
    payment_method character varying(255),
    late_fee numeric,
    remark character varying(255),
    discount numeric,
    sessionid uuid,
    pending_amount_id uuid,
    status character varying,
    receipt_number integer NOT NULL
);


ALTER TABLE dwps_ajmer.fee_deposite OWNER TO postgres;

--
-- Name: fee_deposite_receipt_number_seq; Type: SEQUENCE; Schema: dwps_ajmer; Owner: postgres
--

CREATE SEQUENCE dwps_ajmer.fee_deposite_receipt_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dwps_ajmer.fee_deposite_receipt_number_seq OWNER TO postgres;

--
-- Name: fee_deposite_receipt_number_seq; Type: SEQUENCE OWNED BY; Schema: dwps_ajmer; Owner: postgres
--

ALTER SEQUENCE dwps_ajmer.fee_deposite_receipt_number_seq OWNED BY dwps_ajmer.fee_deposite.receipt_number;


--
-- Name: fee_head_master; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.fee_head_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    order_no numeric
);


ALTER TABLE dwps_ajmer.fee_head_master OWNER TO postgres;

--
-- Name: fee_installment_line_items; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.fee_installment_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_head_master_id uuid,
    general_amount numeric,
    obc_amount numeric,
    sc_amount numeric,
    st_amount numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    fee_master_id uuid,
    fee_master_installment_id uuid
);


ALTER TABLE dwps_ajmer.fee_installment_line_items OWNER TO postgres;

--
-- Name: fee_master; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.fee_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    status character varying,
    classid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    type character varying,
    fee_structure character varying,
    sessionid uuid,
    total_general_fees numeric,
    total_obc_fees numeric,
    total_sc_fees numeric,
    total_st_fees numeric
);


ALTER TABLE dwps_ajmer.fee_master OWNER TO postgres;

--
-- Name: fee_master_installment; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.fee_master_installment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_master_id uuid,
    sessionid uuid,
    lastmodifieddate timestamp without time zone,
    createddate timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    month character varying,
    obc_fee numeric,
    general_fee numeric,
    sc_fee numeric,
    st_fee numeric
);


ALTER TABLE dwps_ajmer.fee_master_installment OWNER TO postgres;

--
-- Name: file; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.file (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    filetype character varying NOT NULL,
    filesize bigint,
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    description character varying,
    parentid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid
);


ALTER TABLE dwps_ajmer.file OWNER TO postgres;

--
-- Name: grade_master; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.grade_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grade text NOT NULL,
    "from" integer NOT NULL,
    "to" integer NOT NULL
);


ALTER TABLE dwps_ajmer.grade_master OWNER TO postgres;

--
-- Name: bookissuesequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bookissuesequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookissuesequence OWNER TO postgres;

--
-- Name: issue; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.issue (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    book_id uuid,
    checkout_date date DEFAULT CURRENT_DATE,
    due_date date,
    return_date date,
    status character varying,
    remark character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    parent_id uuid,
    parent_type character varying,
    book_issue_num character varying DEFAULT ('BI-'::text || lpad((nextval('public.bookissuesequence'::regclass))::text, 5, '0'::text))
);


ALTER TABLE dwps_ajmer.issue OWNER TO postgres;

--
-- Name: language; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.language (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    description character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE dwps_ajmer.language OWNER TO postgres;

--
-- Name: lead; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.lead (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    father_name character varying(100),
    mother_name character varying(100),
    father_qualification character varying(50),
    mother_qualification character varying(50),
    father_occupation character varying(50),
    mother_occupation character varying(50),
    status character varying(50),
    class_id uuid
);


ALTER TABLE dwps_ajmer.lead OWNER TO postgres;

--
-- Name: leave; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.leave (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    contactid uuid,
    fromdate timestamp without time zone,
    enddate timestamp without time zone,
    leavetype character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    studentid uuid
);


ALTER TABLE dwps_ajmer.leave OWNER TO postgres;

--
-- Name: location_master; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.location_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    location text,
    distance numeric,
    status character varying
);


ALTER TABLE dwps_ajmer.location_master OWNER TO postgres;

--
-- Name: pending_amount; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.pending_amount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    dues numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);


ALTER TABLE dwps_ajmer.pending_amount OWNER TO postgres;

--
-- Name: previous_schooling; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.previous_schooling (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_name character varying NOT NULL,
    school_address character varying,
    class character varying,
    grade character varying,
    passed_year character varying,
    phone character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    student_id uuid
);


ALTER TABLE dwps_ajmer.previous_schooling OWNER TO postgres;

--
-- Name: publisher; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.publisher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    status character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE dwps_ajmer.publisher OWNER TO postgres;

--
-- Name: purchase; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.purchase (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    supplier_id uuid,
    book_id uuid,
    quantity integer,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    date date
);


ALTER TABLE dwps_ajmer.purchase OWNER TO postgres;

--
-- Name: quick_launcher; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.quick_launcher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    userid uuid NOT NULL,
    sub_module_url character varying,
    icon character varying,
    status character varying,
    name character varying
);


ALTER TABLE dwps_ajmer.quick_launcher OWNER TO postgres;

--
-- Name: result; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.result (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_schedule_id uuid NOT NULL,
    student_addmission_id uuid NOT NULL,
    obtained_marks double precision NOT NULL,
    ispresent boolean,
    grade_master_id uuid NOT NULL
);


ALTER TABLE dwps_ajmer.result OWNER TO postgres;

--
-- Name: route; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.route (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    locationid uuid,
    transportid uuid,
    order_no text
);


ALTER TABLE dwps_ajmer.route OWNER TO postgres;

--
-- Name: section; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.section (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    class_id uuid,
    strength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contact_id uuid,
    isactive boolean
);


ALTER TABLE dwps_ajmer.section OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    year text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);


ALTER TABLE dwps_ajmer.session OWNER TO postgres;

--
-- Name: settings; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying,
    value character varying,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    createddate date,
    lastmodifieddate date
);


ALTER TABLE dwps_ajmer.settings OWNER TO postgres;

--
-- Name: studentsrsequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.studentsrsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.studentsrsequence OWNER TO postgres;

--
-- Name: student; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.student (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    srno character varying DEFAULT ('SR-'::text || lpad((nextval('public.studentsrsequence'::regclass))::text, 5, '0'::text)),
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    description character varying,
    parentid uuid,
    vehicleid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    isrte boolean DEFAULT false,
    permanentstreet character varying,
    permanentcity character varying,
    permanentpostalcode character varying,
    permanentstate character varying,
    permanentcountry character varying,
    section_id uuid,
    session_id uuid,
    category character varying
);


ALTER TABLE dwps_ajmer.student OWNER TO postgres;

--
-- Name: formsequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.formsequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.formsequence OWNER TO postgres;

--
-- Name: student_addmission; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.student_addmission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    classid uuid,
    dateofaddmission date,
    year character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    formno character varying DEFAULT ('ST-'::text || lpad((nextval('public.formsequence'::regclass))::text, 4, '0'::text)),
    parentid uuid,
    isrte boolean,
    session_id uuid,
    fee_type uuid
);


ALTER TABLE dwps_ajmer.student_addmission OWNER TO postgres;

--
-- Name: student_fee_installments; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.student_fee_installments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    fee_master_installment_id uuid,
    amount numeric,
    deposit_amount numeric,
    deposit_id uuid,
    previous_due numeric,
    status text,
    due_date date,
    orderno integer,
    assign_transport_id uuid,
    transport_fee numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month text,
    session_id uuid
);


ALTER TABLE dwps_ajmer.student_fee_installments OWNER TO postgres;

--
-- Name: subject; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    category character varying,
    type character varying,
    shortname character varying,
    status text
);


ALTER TABLE dwps_ajmer.subject OWNER TO postgres;

--
-- Name: subject_teacher; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.subject_teacher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staffid uuid,
    subjectid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    classid uuid
);


ALTER TABLE dwps_ajmer.subject_teacher OWNER TO postgres;

--
-- Name: supplier; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.supplier (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    contact_person character varying,
    phone character varying,
    email character varying,
    address character varying,
    status character varying,
    createdbyid uuid,
    createddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE dwps_ajmer.supplier OWNER TO postgres;

--
-- Name: syllabus; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.syllabus (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    subject_id uuid,
    description text,
    session_id uuid,
    isactive text
);


ALTER TABLE dwps_ajmer.syllabus OWNER TO postgres;

--
-- Name: time_slot; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.time_slot (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying(255) NOT NULL,
    start_time character varying,
    end_time character varying,
    status character varying(50),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);


ALTER TABLE dwps_ajmer.time_slot OWNER TO postgres;

--
-- Name: timetable; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.timetable (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    contact_id uuid,
    subject_id uuid,
    time_slot_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    section_id uuid,
    start_time character varying,
    end_time character varying,
    status character varying,
    day character varying,
    session_id uuid
);


ALTER TABLE dwps_ajmer.timetable OWNER TO postgres;

--
-- Name: transport; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer.transport (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    driver_id uuid,
    vehicle_no character varying(20),
    type character varying(50),
    seating_capacity integer,
    status character varying(20),
    end_point uuid
);


ALTER TABLE dwps_ajmer.transport OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: dwps_ajmer; Owner: postgres
--

CREATE TABLE dwps_ajmer."user" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying NOT NULL,
    created_date date,
    last_modified_date date,
    email character varying NOT NULL,
    password character varying NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    phone character varying,
    related_user_id uuid,
    companyid uuid
);


ALTER TABLE dwps_ajmer."user" OWNER TO postgres;

--
-- Name: v_book; Type: VIEW; Schema: dwps_ajmer; Owner: postgres
--

CREATE VIEW dwps_ajmer.v_book AS
 SELECT book.id,
    book.title,
    book.author_id,
    author.name AS author_name,
    book.category_id,
    category.name AS category_name,
    book.publisher_id,
    publisher.name AS publisher_name,
    book.language_id,
    language.name AS language_name,
    book.isbn,
    book.publish_date,
    book.status,
    book.missing,
    book.issued,
    book.createdbyid,
    book.createddate,
    book.lastmodifiedbyid,
    book.lastmodifieddate,
    book.total_copies,
    (book.total_copies - (book.missing + book.issued)) AS available
   FROM ((((( SELECT book_1.id,
            book_1.title,
            book_1.author_id,
            book_1.category_id,
            book_1.publisher_id,
            book_1.language_id,
            book_1.isbn,
            book_1.publish_date,
            book_1.status,
            book_1.missing,
            book_1.issued,
            book_1.createdbyid,
            book_1.createddate,
            book_1.lastmodifiedbyid,
            book_1.lastmodifieddate,
            ( SELECT COALESCE(sum(p.quantity), (0)::bigint) AS "coalesce"
                   FROM dwps_ajmer.purchase p
                  WHERE (p.book_id = book_1.id)) AS total_copies
           FROM dwps_ajmer.book book_1) book
     JOIN dwps_ajmer.author ON ((book.author_id = author.id)))
     JOIN dwps_ajmer.category ON ((book.category_id = category.id)))
     JOIN dwps_ajmer.publisher ON ((book.publisher_id = publisher.id)))
     JOIN dwps_ajmer.language ON ((book.language_id = language.id)));


ALTER TABLE dwps_ajmer.v_book OWNER TO postgres;

--
-- Name: v_issue; Type: VIEW; Schema: dwps_ajmer; Owner: postgres
--

CREATE VIEW dwps_ajmer.v_issue AS
 SELECT i.id,
    i.book_id,
    i.book_issue_num,
    b.title AS book_title,
    i.status,
    i.parent_id,
        CASE
            WHEN ((i.parent_type)::text = 'Student'::text) THEN (((s.firstname)::text || ' '::text) || (s.lastname)::text)
            WHEN ((i.parent_type)::text = 'Staff'::text) THEN (((((c.salutation)::text || ' '::text) || (c.firstname)::text) || ' '::text) || (c.lastname)::text)
            ELSE NULL::text
        END AS parent_name,
        CASE
            WHEN ((i.parent_type)::text = 'Student'::text) THEN (s.srno)::text
            WHEN ((i.parent_type)::text = 'Staff'::text) THEN (c.contactno)::text
            ELSE NULL::text
        END AS parent_eid,
    i.parent_type,
    to_char((i.checkout_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS checkout_date,
    to_char((i.due_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS due_date,
    to_char((i.return_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS return_date,
    i.remark,
    i.createdbyid,
    i.createddate,
    i.lastmodifiedbyid,
    i.lastmodifieddate
   FROM (((dwps_ajmer.issue i
     LEFT JOIN dwps_ajmer.book b ON ((i.book_id = b.id)))
     LEFT JOIN dwps_ajmer.student s ON (((i.parent_id = s.id) AND ((i.parent_type)::text = 'Student'::text))))
     LEFT JOIN dwps_ajmer.contact c ON (((i.parent_id = c.id) AND ((i.parent_type)::text = 'Staff'::text))));


ALTER TABLE dwps_ajmer.v_issue OWNER TO postgres;

--
-- Name: v_purchase; Type: VIEW; Schema: dwps_ajmer; Owner: postgres
--

CREATE VIEW dwps_ajmer.v_purchase AS
 SELECT p.id,
    p.supplier_id,
    s.name AS supplier_name,
    s.phone AS supplier_phone,
    s.status AS supplier_status,
    s.email AS supplier_email,
    s.contact_person AS supplier_contact_person,
    s.address AS supplier_address,
    p.book_id,
    b.title AS book_title,
    p.quantity,
    to_char((p.date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS date,
    p.createdbyid,
    p.createddate,
    p.lastmodifiedbyid,
    p.lastmodifieddate
   FROM ((dwps_ajmer.purchase p
     LEFT JOIN dwps_ajmer.supplier s ON ((p.supplier_id = s.id)))
     LEFT JOIN dwps_ajmer.book b ON ((p.book_id = b.id)));


ALTER TABLE dwps_ajmer.v_purchase OWNER TO postgres;

--
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    tenantcode character varying NOT NULL,
    userlicenses integer DEFAULT 0 NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    systememail character varying DEFAULT 'admin@spark.indicrm.io'::character varying NOT NULL,
    adminemail character varying DEFAULT 'admin@spark.indicrm.io'::character varying NOT NULL,
    logourl character varying DEFAULT 'https://spark.indicrm.io/logos/client_logo.png'::character varying,
    sidebarbgurl character varying DEFAULT 'https://spark.indicrm.io/logos/sidebar_background.jpg'::character varying,
    city character varying,
    street character varying,
    pincode character varying,
    state character varying,
    country character varying
);


ALTER TABLE public.company OWNER TO postgres;

--
-- Name: company_module; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_module (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    companyid uuid,
    moduleid uuid
);


ALTER TABLE public.company_module OWNER TO postgres;

--
-- Name: module; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.module (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    status character varying,
    api_name character varying(255),
    icon character varying(255),
    url character varying(255),
    icon_type character varying(255),
    parent_module uuid,
    order_no integer
);


ALTER TABLE public.module OWNER TO postgres;

--
-- Name: permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    status character varying
);


ALTER TABLE public.permission OWNER TO postgres;

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    description character varying,
    status character varying
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: role_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    permissionid uuid,
    roleid uuid NOT NULL,
    name character varying,
    moduleid uuid,
    can_read boolean,
    can_edit boolean,
    can_delete boolean,
    status character varying,
    view_all boolean,
    modify_all boolean,
    can_create boolean
);


ALTER TABLE public.role_permission OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying NOT NULL,
    password character varying NOT NULL,
    email character varying,
    companyid uuid,
    userrole character varying,
    phone numeric
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    userid uuid NOT NULL,
    roleid uuid NOT NULL
);


ALTER TABLE public.user_role OWNER TO postgres;

--
-- Name: assign_subject; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.assign_subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    createdbyid uuid,
    lastmodifiedbyid uuid
);


ALTER TABLE sankriti_ajmer.assign_subject OWNER TO postgres;

--
-- Name: assign_transport; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.assign_transport (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    transport_id uuid,
    drop_location text,
    fare_id uuid,
    fare_amount numeric,
    distance numeric,
    route_direction text,
    sessionid uuid
);


ALTER TABLE sankriti_ajmer.assign_transport OWNER TO postgres;

--
-- Name: assignment; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.assignment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    date date,
    title character varying(255) NOT NULL,
    description text,
    status character varying(50),
    session_id uuid
);


ALTER TABLE sankriti_ajmer.assignment OWNER TO postgres;

--
-- Name: attendance; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    attendance_master_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    present character varying,
    absent character varying
);


ALTER TABLE sankriti_ajmer.attendance OWNER TO postgres;

--
-- Name: attendance_line_item; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.attendance_line_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    attendance_id uuid,
    date date,
    status character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    data json
);


ALTER TABLE sankriti_ajmer.attendance_line_item OWNER TO postgres;

--
-- Name: attendance_master; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.attendance_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    total_lectures character varying,
    type character varying,
    session_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month character varying,
    year character varying
);


ALTER TABLE sankriti_ajmer.attendance_master OWNER TO postgres;

--
-- Name: class; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.class (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    classname character varying NOT NULL,
    maxstrength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    aliasname character varying,
    status character varying,
    session_id uuid,
    session_year character varying
);


ALTER TABLE sankriti_ajmer.class OWNER TO postgres;

--
-- Name: class_timing; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.class_timing (
    id integer NOT NULL,
    name character varying NOT NULL,
    isactive boolean NOT NULL,
    session_id integer NOT NULL,
    created_by uuid,
    modified_by uuid,
    created_date timestamp without time zone,
    modified_date timestamp without time zone
);


ALTER TABLE sankriti_ajmer.class_timing OWNER TO postgres;

--
-- Name: class_timing_id_seq; Type: SEQUENCE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE SEQUENCE sankriti_ajmer.class_timing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sankriti_ajmer.class_timing_id_seq OWNER TO postgres;

--
-- Name: class_timing_id_seq; Type: SEQUENCE OWNED BY; Schema: sankriti_ajmer; Owner: postgres
--

ALTER SEQUENCE sankriti_ajmer.class_timing_id_seq OWNED BY sankriti_ajmer.class_timing.id;


--
-- Name: contact; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.contact (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    salutation character varying,
    firstname character varying NOT NULL,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    profession character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    spousename character varying,
    qualification character varying,
    description character varying,
    parentid uuid,
    department character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contactno character varying DEFAULT ('CTC-'::text || nextval('public.contactsequence'::regclass)),
    religion character varying,
    lastname character varying,
    recordtype character varying
);


ALTER TABLE sankriti_ajmer.contact OWNER TO postgres;

--
-- Name: deposit; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.deposit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    depositfee numeric,
    dateofdeposit timestamp without time zone DEFAULT now(),
    fromdate date,
    todate date,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    receiptno character varying DEFAULT ('R-'::text || lpad((nextval('public.receiptsequence'::regclass))::text, 4, '0'::text))
);


ALTER TABLE sankriti_ajmer.deposit OWNER TO postgres;

--
-- Name: discount; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.discount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    percent numeric(5,2),
    sessionid uuid,
    fee_head_id uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    amount numeric,
    status text
);


ALTER TABLE sankriti_ajmer.discount OWNER TO postgres;

--
-- Name: discount_line_items; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.discount_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    discountid uuid
);


ALTER TABLE sankriti_ajmer.discount_line_items OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    event_type character varying(255) NOT NULL,
    start_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_date date NOT NULL,
    end_time time without time zone NOT NULL,
    description text,
    title character varying(255),
    colorcode character varying(255),
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid,
    status character varying
);


ALTER TABLE sankriti_ajmer.events OWNER TO postgres;

--
-- Name: exam_schedule; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.exam_schedule (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_title_id uuid,
    schedule_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration numeric,
    room_no text,
    examinor_id uuid,
    status text,
    subject_id uuid,
    class_id uuid,
    max_marks integer,
    min_marks integer,
    ispractical boolean,
    session_id uuid
);


ALTER TABLE sankriti_ajmer.exam_schedule OWNER TO postgres;

--
-- Name: exam_title; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.exam_title (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    status text,
    sessionid uuid
);


ALTER TABLE sankriti_ajmer.exam_title OWNER TO postgres;

--
-- Name: fare_master; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.fare_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fare numeric,
    fromdistance numeric,
    todistance numeric,
    status character varying
);


ALTER TABLE sankriti_ajmer.fare_master OWNER TO postgres;

--
-- Name: fee_deposite; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.fee_deposite (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    amount numeric,
    payment_date date,
    payment_method character varying(255),
    late_fee numeric,
    remark character varying(255),
    discount numeric,
    sessionid uuid,
    pending_amount_id uuid,
    status character varying,
    receipt_number integer NOT NULL
);


ALTER TABLE sankriti_ajmer.fee_deposite OWNER TO postgres;

--
-- Name: fee_deposite_receipt_number_seq; Type: SEQUENCE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE SEQUENCE sankriti_ajmer.fee_deposite_receipt_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sankriti_ajmer.fee_deposite_receipt_number_seq OWNER TO postgres;

--
-- Name: fee_deposite_receipt_number_seq; Type: SEQUENCE OWNED BY; Schema: sankriti_ajmer; Owner: postgres
--

ALTER SEQUENCE sankriti_ajmer.fee_deposite_receipt_number_seq OWNED BY sankriti_ajmer.fee_deposite.receipt_number;


--
-- Name: fee_head_master; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.fee_head_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    order_no numeric
);


ALTER TABLE sankriti_ajmer.fee_head_master OWNER TO postgres;

--
-- Name: fee_installment_line_items; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.fee_installment_line_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_head_master_id uuid,
    general_amount numeric,
    obc_amount numeric,
    sc_amount numeric,
    st_amount numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    fee_master_id uuid,
    fee_master_installment_id uuid
);


ALTER TABLE sankriti_ajmer.fee_installment_line_items OWNER TO postgres;

--
-- Name: fee_master; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.fee_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    status character varying,
    classid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    type character varying,
    fee_structure character varying,
    sessionid uuid,
    total_general_fees numeric,
    total_obc_fees numeric,
    total_sc_fees numeric,
    total_st_fees numeric
);


ALTER TABLE sankriti_ajmer.fee_master OWNER TO postgres;

--
-- Name: fee_master_installment; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.fee_master_installment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fee_master_id uuid,
    sessionid uuid,
    lastmodifieddate timestamp without time zone,
    createddate timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    status character varying,
    month character varying,
    obc_fee numeric,
    general_fee numeric,
    sc_fee numeric,
    st_fee numeric
);


ALTER TABLE sankriti_ajmer.fee_master_installment OWNER TO postgres;

--
-- Name: file; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.file (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    filetype character varying NOT NULL,
    filesize bigint,
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    description character varying,
    parentid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    lastmodifiedbyid uuid
);


ALTER TABLE sankriti_ajmer.file OWNER TO postgres;

--
-- Name: grade_master; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.grade_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grade text NOT NULL,
    "from" integer NOT NULL,
    "to" integer NOT NULL
);


ALTER TABLE sankriti_ajmer.grade_master OWNER TO postgres;

--
-- Name: lead; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.lead (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    father_name character varying(100),
    mother_name character varying(100),
    father_qualification character varying(50),
    mother_qualification character varying(50),
    father_occupation character varying(50),
    mother_occupation character varying(50),
    status character varying(50),
    class_id uuid
);


ALTER TABLE sankriti_ajmer.lead OWNER TO postgres;

--
-- Name: leave; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.leave (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    contactid uuid,
    fromdate timestamp without time zone,
    enddate timestamp without time zone,
    leavetype character varying,
    description character varying,
    lastmodifieddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createddate timestamp without time zone DEFAULT '2023-06-22 18:04:25.933616'::timestamp without time zone,
    createdbyid uuid,
    lastmodifiedbyid uuid,
    studentid uuid
);


ALTER TABLE sankriti_ajmer.leave OWNER TO postgres;

--
-- Name: location_master; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.location_master (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    location text,
    distance numeric,
    status character varying
);


ALTER TABLE sankriti_ajmer.location_master OWNER TO postgres;

--
-- Name: pending_amount; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.pending_amount (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    dues numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);


ALTER TABLE sankriti_ajmer.pending_amount OWNER TO postgres;

--
-- Name: previous_schooling; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.previous_schooling (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_name character varying NOT NULL,
    school_address character varying,
    class character varying,
    grade character varying,
    passed_year character varying,
    phone character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    student_id uuid
);


ALTER TABLE sankriti_ajmer.previous_schooling OWNER TO postgres;

--
-- Name: quick_launcher; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.quick_launcher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    userid uuid NOT NULL,
    sub_module_url character varying,
    icon character varying,
    status character varying,
    name character varying
);


ALTER TABLE sankriti_ajmer.quick_launcher OWNER TO postgres;

--
-- Name: result; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.result (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    exam_schedule_id uuid NOT NULL,
    student_addmission_id uuid NOT NULL,
    obtained_marks double precision NOT NULL,
    ispresent boolean,
    grade_master_id uuid NOT NULL
);


ALTER TABLE sankriti_ajmer.result OWNER TO postgres;

--
-- Name: route; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.route (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    locationid uuid,
    transportid uuid,
    order_no text
);


ALTER TABLE sankriti_ajmer.route OWNER TO postgres;

--
-- Name: section; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.section (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    class_id uuid,
    strength character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    contact_id uuid,
    isactive boolean
);


ALTER TABLE sankriti_ajmer.section OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    year text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);


ALTER TABLE sankriti_ajmer.session OWNER TO postgres;

--
-- Name: student; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.student (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    firstname character varying NOT NULL,
    lastname character varying,
    srno character varying DEFAULT ('SR-'::text || lpad((nextval('public.studentsrsequence'::regclass))::text, 5, '0'::text)),
    religion character varying,
    dateofbirth date,
    gender character varying,
    email character varying,
    adharnumber character varying,
    phone character varying,
    pincode character varying,
    street character varying,
    city character varying,
    state character varying,
    country character varying,
    classid uuid,
    description character varying,
    parentid uuid,
    vehicleid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    isrte boolean DEFAULT false,
    permanentstreet character varying,
    permanentcity character varying,
    permanentpostalcode character varying,
    permanentstate character varying,
    permanentcountry character varying,
    section_id uuid,
    session_id uuid,
    category character varying
);


ALTER TABLE sankriti_ajmer.student OWNER TO postgres;

--
-- Name: student_addmission; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.student_addmission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    studentid uuid,
    classid uuid,
    dateofaddmission date,
    year character varying,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    formno character varying DEFAULT ('ST-'::text || lpad((nextval('public.formsequence'::regclass))::text, 4, '0'::text)),
    parentid uuid,
    isrte boolean,
    session_id uuid,
    fee_type uuid
);


ALTER TABLE sankriti_ajmer.student_addmission OWNER TO postgres;

--
-- Name: student_fee_installments; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.student_fee_installments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_addmission_id uuid,
    fee_master_installment_id uuid,
    amount numeric,
    deposit_amount numeric,
    deposit_id uuid,
    previous_due numeric,
    status text,
    due_date date,
    orderno integer,
    assign_transport_id uuid,
    transport_fee numeric,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    month text,
    session_id uuid
);


ALTER TABLE sankriti_ajmer.student_fee_installments OWNER TO postgres;

--
-- Name: subject; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.subject (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    category character varying,
    type character varying,
    shortname character varying,
    status text
);


ALTER TABLE sankriti_ajmer.subject OWNER TO postgres;

--
-- Name: subject_teacher; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.subject_teacher (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staffid uuid,
    subjectid uuid,
    lastmodifieddate timestamp without time zone DEFAULT now(),
    createddate timestamp without time zone DEFAULT now(),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    classid uuid
);


ALTER TABLE sankriti_ajmer.subject_teacher OWNER TO postgres;

--
-- Name: syllabus; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.syllabus (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid,
    section_id uuid,
    subject_id uuid,
    description text,
    session_id uuid,
    isactive text
);


ALTER TABLE sankriti_ajmer.syllabus OWNER TO postgres;

--
-- Name: time_slot; Type: TABLE; Schema: sankriti_ajmer; Owner: postgres
--

CREATE TABLE sankriti_ajmer.time_slot (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying(255) NOT NULL,
    start_time character varying,
    end_time character varying,
    status character varying(50),
    createdbyid uuid,
    lastmodifiedbyid uuid,
    session_id uuid
);


ALTER TABLE sankriti_ajmer.time_slot OWNER TO postgres;

--
-- Name: class_timing id; Type: DEFAULT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.class_timing ALTER COLUMN id SET DEFAULT nextval('dwps_ajmer.class_timing_id_seq'::regclass);


--
-- Name: fee_deposite receipt_number; Type: DEFAULT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fee_deposite ALTER COLUMN receipt_number SET DEFAULT nextval('dwps_ajmer.fee_deposite_receipt_number_seq'::regclass);


--
-- Data for Name: assign_subject; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.assign_subject (id, class_id, subject_id, createdbyid, lastmodifiedbyid) FROM stdin;
\.
COPY dwps_ajmer.assign_subject (id, class_id, subject_id, createdbyid, lastmodifiedbyid) FROM '$$PATH$$/4127.dat';

--
-- Data for Name: assign_transport; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.assign_transport (id, student_admission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) FROM stdin;
\.
COPY dwps_ajmer.assign_transport (id, student_admission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) FROM '$$PATH$$/4128.dat';

--
-- Data for Name: assignment; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.assignment (id, class_id, subject_id, date, title, description, status, session_id) FROM stdin;
\.
COPY dwps_ajmer.assignment (id, class_id, subject_id, date, title, description, status, session_id) FROM '$$PATH$$/4129.dat';

--
-- Data for Name: attendance; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.attendance (id, student_id, attendance_master_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, present, absent) FROM stdin;
\.
COPY dwps_ajmer.attendance (id, student_id, attendance_master_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, present, absent) FROM '$$PATH$$/4130.dat';

--
-- Data for Name: attendance_line_item; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.attendance_line_item (id, attendance_id, date, status, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, data) FROM stdin;
\.
COPY dwps_ajmer.attendance_line_item (id, attendance_id, date, status, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, data) FROM '$$PATH$$/4131.dat';

--
-- Data for Name: attendance_master; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.attendance_master (id, class_id, section_id, total_lectures, type, session_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, year) FROM stdin;
\.
COPY dwps_ajmer.attendance_master (id, class_id, section_id, total_lectures, type, session_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, year) FROM '$$PATH$$/4132.dat';

--
-- Data for Name: author; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.author (id, name, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
\.
COPY dwps_ajmer.author (id, name, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM '$$PATH$$/4133.dat';

--
-- Data for Name: book; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.book (id, title, author_id, isbn, category_id, publisher_id, publish_date, status, language_id, missing, issued, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
\.
COPY dwps_ajmer.book (id, title, author_id, isbn, category_id, publisher_id, publish_date, status, language_id, missing, issued, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM '$$PATH$$/4134.dat';

--
-- Data for Name: category; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.category (id, name, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, description) FROM stdin;
\.
COPY dwps_ajmer.category (id, name, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, description) FROM '$$PATH$$/4135.dat';

--
-- Data for Name: class; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.class (id, classname, maxstrength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, aliasname, status, session_id, session_year) FROM stdin;
\.
COPY dwps_ajmer.class (id, classname, maxstrength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, aliasname, status, session_id, session_year) FROM '$$PATH$$/4136.dat';

--
-- Data for Name: class_timing; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.class_timing (id, name, isactive, session_id, created_by, modified_by, created_date, modified_date) FROM stdin;
\.
COPY dwps_ajmer.class_timing (id, name, isactive, session_id, created_by, modified_by, created_date, modified_date) FROM '$$PATH$$/4137.dat';

--
-- Data for Name: contact; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.contact (id, salutation, firstname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, department, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contactno, religion, lastname, recordtype) FROM stdin;
\.
COPY dwps_ajmer.contact (id, salutation, firstname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, department, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contactno, religion, lastname, recordtype) FROM '$$PATH$$/4140.dat';

--
-- Data for Name: deposit; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.deposit (id, studentid, depositfee, dateofdeposit, fromdate, todate, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, receiptno) FROM stdin;
\.
COPY dwps_ajmer.deposit (id, studentid, depositfee, dateofdeposit, fromdate, todate, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, receiptno) FROM '$$PATH$$/4142.dat';

--
-- Data for Name: discount; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.discount (id, name, percent, sessionid, fee_head_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, amount, status) FROM stdin;
\.
COPY dwps_ajmer.discount (id, name, percent, sessionid, fee_head_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, amount, status) FROM '$$PATH$$/4143.dat';

--
-- Data for Name: discount_line_items; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.discount_line_items (id, student_addmission_id, discountid) FROM stdin;
\.
COPY dwps_ajmer.discount_line_items (id, student_addmission_id, discountid) FROM '$$PATH$$/4144.dat';

--
-- Data for Name: events; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.events (id, event_type, start_date, start_time, end_date, end_time, description, title, colorcode, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id, status) FROM stdin;
\.
COPY dwps_ajmer.events (id, event_type, start_date, start_time, end_date, end_time, description, title, colorcode, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id, status) FROM '$$PATH$$/4145.dat';

--
-- Data for Name: exam_schedule; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.exam_schedule (id, exam_title_id, schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical, sessionid) FROM stdin;
\.
COPY dwps_ajmer.exam_schedule (id, exam_title_id, schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical, sessionid) FROM '$$PATH$$/4146.dat';

--
-- Data for Name: exam_title; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.exam_title (id, name, status, sessionid) FROM stdin;
\.
COPY dwps_ajmer.exam_title (id, name, status, sessionid) FROM '$$PATH$$/4147.dat';

--
-- Data for Name: fare_master; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.fare_master (id, fare, fromdistance, todistance, status) FROM stdin;
\.
COPY dwps_ajmer.fare_master (id, fare, fromdistance, todistance, status) FROM '$$PATH$$/4148.dat';

--
-- Data for Name: fee_deposite; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.fee_deposite (id, student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status, receipt_number) FROM stdin;
\.
COPY dwps_ajmer.fee_deposite (id, student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status, receipt_number) FROM '$$PATH$$/4149.dat';

--
-- Data for Name: fee_head_master; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.fee_head_master (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, order_no) FROM stdin;
\.
COPY dwps_ajmer.fee_head_master (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, order_no) FROM '$$PATH$$/4151.dat';

--
-- Data for Name: fee_installment_line_items; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.fee_installment_line_items (id, fee_head_master_id, general_amount, obc_amount, sc_amount, st_amount, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, fee_master_id, fee_master_installment_id) FROM stdin;
\.
COPY dwps_ajmer.fee_installment_line_items (id, fee_head_master_id, general_amount, obc_amount, sc_amount, st_amount, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, fee_master_id, fee_master_installment_id) FROM '$$PATH$$/4152.dat';

--
-- Data for Name: fee_master; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.fee_master (id, status, classid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, type, fee_structure, sessionid, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees) FROM stdin;
\.
COPY dwps_ajmer.fee_master (id, status, classid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, type, fee_structure, sessionid, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees) FROM '$$PATH$$/4153.dat';

--
-- Data for Name: fee_master_installment; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.fee_master_installment (id, fee_master_id, sessionid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, month, obc_fee, general_fee, sc_fee, st_fee) FROM stdin;
\.
COPY dwps_ajmer.fee_master_installment (id, fee_master_id, sessionid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, month, obc_fee, general_fee, sc_fee, st_fee) FROM '$$PATH$$/4154.dat';

--
-- Data for Name: file; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.file (id, title, filetype, filesize, createddate, createdbyid, description, parentid, lastmodifieddate, lastmodifiedbyid) FROM stdin;
\.
COPY dwps_ajmer.file (id, title, filetype, filesize, createddate, createdbyid, description, parentid, lastmodifieddate, lastmodifiedbyid) FROM '$$PATH$$/4155.dat';

--
-- Data for Name: grade_master; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.grade_master (id, grade, "from", "to") FROM stdin;
\.
COPY dwps_ajmer.grade_master (id, grade, "from", "to") FROM '$$PATH$$/4156.dat';

--
-- Data for Name: issue; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.issue (id, book_id, checkout_date, due_date, return_date, status, remark, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, parent_id, parent_type, book_issue_num) FROM stdin;
\.
COPY dwps_ajmer.issue (id, book_id, checkout_date, due_date, return_date, status, remark, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, parent_id, parent_type, book_issue_num) FROM '$$PATH$$/4158.dat';

--
-- Data for Name: language; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.language (id, name, description, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
\.
COPY dwps_ajmer.language (id, name, description, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM '$$PATH$$/4159.dat';

--
-- Data for Name: lead; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.lead (id, firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation, status, class_id) FROM stdin;
\.
COPY dwps_ajmer.lead (id, firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation, status, class_id) FROM '$$PATH$$/4160.dat';

--
-- Data for Name: leave; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.leave (id, contactid, fromdate, enddate, leavetype, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, studentid) FROM stdin;
\.
COPY dwps_ajmer.leave (id, contactid, fromdate, enddate, leavetype, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, studentid) FROM '$$PATH$$/4161.dat';

--
-- Data for Name: location_master; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.location_master (id, location, distance, status) FROM stdin;
\.
COPY dwps_ajmer.location_master (id, location, distance, status) FROM '$$PATH$$/4162.dat';

--
-- Data for Name: pending_amount; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.pending_amount (id, student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
\.
COPY dwps_ajmer.pending_amount (id, student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) FROM '$$PATH$$/4163.dat';

--
-- Data for Name: previous_schooling; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.previous_schooling (id, school_name, school_address, class, grade, passed_year, phone, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, student_id) FROM stdin;
\.
COPY dwps_ajmer.previous_schooling (id, school_name, school_address, class, grade, passed_year, phone, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, student_id) FROM '$$PATH$$/4164.dat';

--
-- Data for Name: publisher; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.publisher (id, name, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
\.
COPY dwps_ajmer.publisher (id, name, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM '$$PATH$$/4165.dat';

--
-- Data for Name: purchase; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.purchase (id, supplier_id, book_id, quantity, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, date) FROM stdin;
\.
COPY dwps_ajmer.purchase (id, supplier_id, book_id, quantity, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, date) FROM '$$PATH$$/4166.dat';

--
-- Data for Name: quick_launcher; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.quick_launcher (id, userid, sub_module_url, icon, status, name) FROM stdin;
\.
COPY dwps_ajmer.quick_launcher (id, userid, sub_module_url, icon, status, name) FROM '$$PATH$$/4167.dat';

--
-- Data for Name: result; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.result (id, exam_schedule_id, student_addmission_id, obtained_marks, ispresent, grade_master_id) FROM stdin;
\.
COPY dwps_ajmer.result (id, exam_schedule_id, student_addmission_id, obtained_marks, ispresent, grade_master_id) FROM '$$PATH$$/4168.dat';

--
-- Data for Name: route; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.route (id, locationid, transportid, order_no) FROM stdin;
\.
COPY dwps_ajmer.route (id, locationid, transportid, order_no) FROM '$$PATH$$/4169.dat';

--
-- Data for Name: section; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.section (id, name, class_id, strength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contact_id, isactive) FROM stdin;
\.
COPY dwps_ajmer.section (id, name, class_id, strength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contact_id, isactive) FROM '$$PATH$$/4170.dat';

--
-- Data for Name: session; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.session (id, year, startdate, enddate) FROM stdin;
\.
COPY dwps_ajmer.session (id, year, startdate, enddate) FROM '$$PATH$$/4171.dat';

--
-- Data for Name: settings; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.settings (id, key, value, createdbyid, lastmodifiedbyid, createddate, lastmodifieddate) FROM stdin;
\.
COPY dwps_ajmer.settings (id, key, value, createdbyid, lastmodifiedbyid, createddate, lastmodifieddate) FROM '$$PATH$$/4172.dat';

--
-- Data for Name: student; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.student (id, firstname, lastname, srno, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, parentid, vehicleid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, isrte, permanentstreet, permanentcity, permanentpostalcode, permanentstate, permanentcountry, section_id, session_id, category) FROM stdin;
\.
COPY dwps_ajmer.student (id, firstname, lastname, srno, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, parentid, vehicleid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, isrte, permanentstreet, permanentcity, permanentpostalcode, permanentstate, permanentcountry, section_id, session_id, category) FROM '$$PATH$$/4174.dat';

--
-- Data for Name: student_addmission; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.student_addmission (id, studentid, classid, dateofaddmission, year, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, formno, parentid, isrte, session_id, fee_type) FROM stdin;
\.
COPY dwps_ajmer.student_addmission (id, studentid, classid, dateofaddmission, year, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, formno, parentid, isrte, session_id, fee_type) FROM '$$PATH$$/4176.dat';

--
-- Data for Name: student_fee_installments; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.student_fee_installments (id, student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, session_id) FROM stdin;
\.
COPY dwps_ajmer.student_fee_installments (id, student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, session_id) FROM '$$PATH$$/4177.dat';

--
-- Data for Name: subject; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.subject (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, category, type, shortname, status) FROM stdin;
\.
COPY dwps_ajmer.subject (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, category, type, shortname, status) FROM '$$PATH$$/4178.dat';

--
-- Data for Name: subject_teacher; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.subject_teacher (id, staffid, subjectid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, classid) FROM stdin;
\.
COPY dwps_ajmer.subject_teacher (id, staffid, subjectid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, classid) FROM '$$PATH$$/4179.dat';

--
-- Data for Name: supplier; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.supplier (id, name, contact_person, phone, email, address, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM stdin;
\.
COPY dwps_ajmer.supplier (id, name, contact_person, phone, email, address, status, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate) FROM '$$PATH$$/4180.dat';

--
-- Data for Name: syllabus; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.syllabus (id, class_id, section_id, subject_id, description, session_id, isactive) FROM stdin;
\.
COPY dwps_ajmer.syllabus (id, class_id, section_id, subject_id, description, session_id, isactive) FROM '$$PATH$$/4181.dat';

--
-- Data for Name: time_slot; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.time_slot (id, type, start_time, end_time, status, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
\.
COPY dwps_ajmer.time_slot (id, type, start_time, end_time, status, createdbyid, lastmodifiedbyid, session_id) FROM '$$PATH$$/4182.dat';

--
-- Data for Name: timetable; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.timetable (id, class_id, contact_id, subject_id, time_slot_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, section_id, start_time, end_time, status, day, session_id) FROM stdin;
\.
COPY dwps_ajmer.timetable (id, class_id, contact_id, subject_id, time_slot_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, section_id, start_time, end_time, status, day, session_id) FROM '$$PATH$$/4183.dat';

--
-- Data for Name: transport; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer.transport (id, driver_id, vehicle_no, type, seating_capacity, status, end_point) FROM stdin;
\.
COPY dwps_ajmer.transport (id, driver_id, vehicle_no, type, seating_capacity, status, end_point) FROM '$$PATH$$/4184.dat';

--
-- Data for Name: user; Type: TABLE DATA; Schema: dwps_ajmer; Owner: postgres
--

COPY dwps_ajmer."user" (id, type, created_date, last_modified_date, email, password, firstname, lastname, phone, related_user_id, companyid) FROM stdin;
\.
COPY dwps_ajmer."user" (id, type, created_date, last_modified_date, email, password, firstname, lastname, phone, related_user_id, companyid) FROM '$$PATH$$/4185.dat';

--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company (id, name, tenantcode, userlicenses, isactive, systememail, adminemail, logourl, sidebarbgurl, city, street, pincode, state, country) FROM stdin;
\.
COPY public.company (id, name, tenantcode, userlicenses, isactive, systememail, adminemail, logourl, sidebarbgurl, city, street, pincode, state, country) FROM '$$PATH$$/4186.dat';

--
-- Data for Name: company_module; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_module (id, companyid, moduleid) FROM stdin;
\.
COPY public.company_module (id, companyid, moduleid) FROM '$$PATH$$/4187.dat';

--
-- Data for Name: module; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.module (id, name, status, api_name, icon, url, icon_type, parent_module, order_no) FROM stdin;
\.
COPY public.module (id, name, status, api_name, icon, url, icon_type, parent_module, order_no) FROM '$$PATH$$/4188.dat';

--
-- Data for Name: permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permission (id, name, status) FROM stdin;
\.
COPY public.permission (id, name, status) FROM '$$PATH$$/4189.dat';

--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (id, name, description, status) FROM stdin;
\.
COPY public.role (id, name, description, status) FROM '$$PATH$$/4190.dat';

--
-- Data for Name: role_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permission (id, permissionid, roleid, name, moduleid, can_read, can_edit, can_delete, status, view_all, modify_all, can_create) FROM stdin;
\.
COPY public.role_permission (id, permissionid, roleid, name, moduleid, can_read, can_edit, can_delete, status, view_all, modify_all, can_create) FROM '$$PATH$$/4191.dat';

--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, firstname, lastname, password, email, companyid, userrole, phone) FROM stdin;
\.
COPY public."user" (id, firstname, lastname, password, email, companyid, userrole, phone) FROM '$$PATH$$/4192.dat';

--
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role (id, userid, roleid) FROM stdin;
\.
COPY public.user_role (id, userid, roleid) FROM '$$PATH$$/4193.dat';

--
-- Data for Name: assign_subject; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.assign_subject (id, class_id, subject_id, createdbyid, lastmodifiedbyid) FROM stdin;
\.
COPY sankriti_ajmer.assign_subject (id, class_id, subject_id, createdbyid, lastmodifiedbyid) FROM '$$PATH$$/4194.dat';

--
-- Data for Name: assign_transport; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.assign_transport (id, student_addmission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) FROM stdin;
\.
COPY sankriti_ajmer.assign_transport (id, student_addmission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) FROM '$$PATH$$/4195.dat';

--
-- Data for Name: assignment; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.assignment (id, class_id, subject_id, date, title, description, status, session_id) FROM stdin;
\.
COPY sankriti_ajmer.assignment (id, class_id, subject_id, date, title, description, status, session_id) FROM '$$PATH$$/4196.dat';

--
-- Data for Name: attendance; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.attendance (id, student_id, attendance_master_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, present, absent) FROM stdin;
\.
COPY sankriti_ajmer.attendance (id, student_id, attendance_master_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, present, absent) FROM '$$PATH$$/4197.dat';

--
-- Data for Name: attendance_line_item; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.attendance_line_item (id, attendance_id, date, status, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, data) FROM stdin;
\.
COPY sankriti_ajmer.attendance_line_item (id, attendance_id, date, status, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, data) FROM '$$PATH$$/4198.dat';

--
-- Data for Name: attendance_master; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.attendance_master (id, class_id, section_id, total_lectures, type, session_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, year) FROM stdin;
\.
COPY sankriti_ajmer.attendance_master (id, class_id, section_id, total_lectures, type, session_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, year) FROM '$$PATH$$/4199.dat';

--
-- Data for Name: class; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.class (id, classname, maxstrength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, aliasname, status, session_id, session_year) FROM stdin;
\.
COPY sankriti_ajmer.class (id, classname, maxstrength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, aliasname, status, session_id, session_year) FROM '$$PATH$$/4200.dat';

--
-- Data for Name: class_timing; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.class_timing (id, name, isactive, session_id, created_by, modified_by, created_date, modified_date) FROM stdin;
\.
COPY sankriti_ajmer.class_timing (id, name, isactive, session_id, created_by, modified_by, created_date, modified_date) FROM '$$PATH$$/4201.dat';

--
-- Data for Name: contact; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.contact (id, salutation, firstname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, department, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contactno, religion, lastname, recordtype) FROM stdin;
\.
COPY sankriti_ajmer.contact (id, salutation, firstname, dateofbirth, gender, email, adharnumber, phone, profession, pincode, street, city, state, country, classid, spousename, qualification, description, parentid, department, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contactno, religion, lastname, recordtype) FROM '$$PATH$$/4203.dat';

--
-- Data for Name: deposit; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.deposit (id, studentid, depositfee, dateofdeposit, fromdate, todate, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, receiptno) FROM stdin;
\.
COPY sankriti_ajmer.deposit (id, studentid, depositfee, dateofdeposit, fromdate, todate, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, receiptno) FROM '$$PATH$$/4204.dat';

--
-- Data for Name: discount; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.discount (id, name, percent, sessionid, fee_head_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, amount, status) FROM stdin;
\.
COPY sankriti_ajmer.discount (id, name, percent, sessionid, fee_head_id, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, amount, status) FROM '$$PATH$$/4205.dat';

--
-- Data for Name: discount_line_items; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.discount_line_items (id, student_addmission_id, discountid) FROM stdin;
\.
COPY sankriti_ajmer.discount_line_items (id, student_addmission_id, discountid) FROM '$$PATH$$/4206.dat';

--
-- Data for Name: events; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.events (id, event_type, start_date, start_time, end_date, end_time, description, title, colorcode, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id, status) FROM stdin;
\.
COPY sankriti_ajmer.events (id, event_type, start_date, start_time, end_date, end_time, description, title, colorcode, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id, status) FROM '$$PATH$$/4207.dat';

--
-- Data for Name: exam_schedule; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.exam_schedule (id, exam_title_id, schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical, session_id) FROM stdin;
\.
COPY sankriti_ajmer.exam_schedule (id, exam_title_id, schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical, session_id) FROM '$$PATH$$/4208.dat';

--
-- Data for Name: exam_title; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.exam_title (id, name, status, sessionid) FROM stdin;
\.
COPY sankriti_ajmer.exam_title (id, name, status, sessionid) FROM '$$PATH$$/4209.dat';

--
-- Data for Name: fare_master; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.fare_master (id, fare, fromdistance, todistance, status) FROM stdin;
\.
COPY sankriti_ajmer.fare_master (id, fare, fromdistance, todistance, status) FROM '$$PATH$$/4210.dat';

--
-- Data for Name: fee_deposite; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.fee_deposite (id, student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status, receipt_number) FROM stdin;
\.
COPY sankriti_ajmer.fee_deposite (id, student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status, receipt_number) FROM '$$PATH$$/4211.dat';

--
-- Data for Name: fee_head_master; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.fee_head_master (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, order_no) FROM stdin;
\.
COPY sankriti_ajmer.fee_head_master (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, order_no) FROM '$$PATH$$/4213.dat';

--
-- Data for Name: fee_installment_line_items; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.fee_installment_line_items (id, fee_head_master_id, general_amount, obc_amount, sc_amount, st_amount, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, fee_master_id, fee_master_installment_id) FROM stdin;
\.
COPY sankriti_ajmer.fee_installment_line_items (id, fee_head_master_id, general_amount, obc_amount, sc_amount, st_amount, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, fee_master_id, fee_master_installment_id) FROM '$$PATH$$/4214.dat';

--
-- Data for Name: fee_master; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.fee_master (id, status, classid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, type, fee_structure, sessionid, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees) FROM stdin;
\.
COPY sankriti_ajmer.fee_master (id, status, classid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, type, fee_structure, sessionid, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees) FROM '$$PATH$$/4215.dat';

--
-- Data for Name: fee_master_installment; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.fee_master_installment (id, fee_master_id, sessionid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, month, obc_fee, general_fee, sc_fee, st_fee) FROM stdin;
\.
COPY sankriti_ajmer.fee_master_installment (id, fee_master_id, sessionid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, status, month, obc_fee, general_fee, sc_fee, st_fee) FROM '$$PATH$$/4216.dat';

--
-- Data for Name: file; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.file (id, title, filetype, filesize, createddate, createdbyid, description, parentid, lastmodifieddate, lastmodifiedbyid) FROM stdin;
\.
COPY sankriti_ajmer.file (id, title, filetype, filesize, createddate, createdbyid, description, parentid, lastmodifieddate, lastmodifiedbyid) FROM '$$PATH$$/4217.dat';

--
-- Data for Name: grade_master; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.grade_master (id, grade, "from", "to") FROM stdin;
\.
COPY sankriti_ajmer.grade_master (id, grade, "from", "to") FROM '$$PATH$$/4218.dat';

--
-- Data for Name: lead; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.lead (id, firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation, status, class_id) FROM stdin;
\.
COPY sankriti_ajmer.lead (id, firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, father_name, mother_name, father_qualification, mother_qualification, father_occupation, mother_occupation, status, class_id) FROM '$$PATH$$/4219.dat';

--
-- Data for Name: leave; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.leave (id, contactid, fromdate, enddate, leavetype, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, studentid) FROM stdin;
\.
COPY sankriti_ajmer.leave (id, contactid, fromdate, enddate, leavetype, description, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, studentid) FROM '$$PATH$$/4220.dat';

--
-- Data for Name: location_master; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.location_master (id, location, distance, status) FROM stdin;
\.
COPY sankriti_ajmer.location_master (id, location, distance, status) FROM '$$PATH$$/4221.dat';

--
-- Data for Name: pending_amount; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.pending_amount (id, student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
\.
COPY sankriti_ajmer.pending_amount (id, student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) FROM '$$PATH$$/4222.dat';

--
-- Data for Name: previous_schooling; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.previous_schooling (id, school_name, school_address, class, grade, passed_year, phone, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, student_id) FROM stdin;
\.
COPY sankriti_ajmer.previous_schooling (id, school_name, school_address, class, grade, passed_year, phone, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, student_id) FROM '$$PATH$$/4223.dat';

--
-- Data for Name: quick_launcher; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.quick_launcher (id, userid, sub_module_url, icon, status, name) FROM stdin;
\.
COPY sankriti_ajmer.quick_launcher (id, userid, sub_module_url, icon, status, name) FROM '$$PATH$$/4224.dat';

--
-- Data for Name: result; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.result (id, exam_schedule_id, student_addmission_id, obtained_marks, ispresent, grade_master_id) FROM stdin;
\.
COPY sankriti_ajmer.result (id, exam_schedule_id, student_addmission_id, obtained_marks, ispresent, grade_master_id) FROM '$$PATH$$/4225.dat';

--
-- Data for Name: route; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.route (id, locationid, transportid, order_no) FROM stdin;
\.
COPY sankriti_ajmer.route (id, locationid, transportid, order_no) FROM '$$PATH$$/4226.dat';

--
-- Data for Name: section; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.section (id, name, class_id, strength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contact_id, isactive) FROM stdin;
\.
COPY sankriti_ajmer.section (id, name, class_id, strength, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, contact_id, isactive) FROM '$$PATH$$/4227.dat';

--
-- Data for Name: session; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.session (id, year, startdate, enddate) FROM stdin;
\.
COPY sankriti_ajmer.session (id, year, startdate, enddate) FROM '$$PATH$$/4228.dat';

--
-- Data for Name: student; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.student (id, firstname, lastname, srno, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, parentid, vehicleid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, isrte, permanentstreet, permanentcity, permanentpostalcode, permanentstate, permanentcountry, section_id, session_id, category) FROM stdin;
\.
COPY sankriti_ajmer.student (id, firstname, lastname, srno, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, parentid, vehicleid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, isrte, permanentstreet, permanentcity, permanentpostalcode, permanentstate, permanentcountry, section_id, session_id, category) FROM '$$PATH$$/4229.dat';

--
-- Data for Name: student_addmission; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.student_addmission (id, studentid, classid, dateofaddmission, year, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, formno, parentid, isrte, session_id, fee_type) FROM stdin;
\.
COPY sankriti_ajmer.student_addmission (id, studentid, classid, dateofaddmission, year, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, formno, parentid, isrte, session_id, fee_type) FROM '$$PATH$$/4230.dat';

--
-- Data for Name: student_fee_installments; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.student_fee_installments (id, student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, session_id) FROM stdin;
\.
COPY sankriti_ajmer.student_fee_installments (id, student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, month, session_id) FROM '$$PATH$$/4231.dat';

--
-- Data for Name: subject; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.subject (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, category, type, shortname, status) FROM stdin;
\.
COPY sankriti_ajmer.subject (id, name, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, category, type, shortname, status) FROM '$$PATH$$/4232.dat';

--
-- Data for Name: subject_teacher; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.subject_teacher (id, staffid, subjectid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, classid) FROM stdin;
\.
COPY sankriti_ajmer.subject_teacher (id, staffid, subjectid, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, classid) FROM '$$PATH$$/4233.dat';

--
-- Data for Name: syllabus; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.syllabus (id, class_id, section_id, subject_id, description, session_id, isactive) FROM stdin;
\.
COPY sankriti_ajmer.syllabus (id, class_id, section_id, subject_id, description, session_id, isactive) FROM '$$PATH$$/4234.dat';

--
-- Data for Name: time_slot; Type: TABLE DATA; Schema: sankriti_ajmer; Owner: postgres
--

COPY sankriti_ajmer.time_slot (id, type, start_time, end_time, status, createdbyid, lastmodifiedbyid, session_id) FROM stdin;
\.
COPY sankriti_ajmer.time_slot (id, type, start_time, end_time, status, createdbyid, lastmodifiedbyid, session_id) FROM '$$PATH$$/4235.dat';

--
-- Name: class_timing_id_seq; Type: SEQUENCE SET; Schema: dwps_ajmer; Owner: postgres
--

SELECT pg_catalog.setval('dwps_ajmer.class_timing_id_seq', 2, true);


--
-- Name: fee_deposite_receipt_number_seq; Type: SEQUENCE SET; Schema: dwps_ajmer; Owner: postgres
--

SELECT pg_catalog.setval('dwps_ajmer.fee_deposite_receipt_number_seq', 1001, false);


--
-- Name: bookissuesequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookissuesequence', 1, false);


--
-- Name: contactsequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contactsequence', 304, true);


--
-- Name: formsequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.formsequence', 42, true);


--
-- Name: receiptsequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.receiptsequence', 19, true);


--
-- Name: studentsrsequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.studentsrsequence', 29, true);


--
-- Name: class_timing_id_seq; Type: SEQUENCE SET; Schema: sankriti_ajmer; Owner: postgres
--

SELECT pg_catalog.setval('sankriti_ajmer.class_timing_id_seq', 1, false);


--
-- Name: fee_deposite_receipt_number_seq; Type: SEQUENCE SET; Schema: sankriti_ajmer; Owner: postgres
--

SELECT pg_catalog.setval('sankriti_ajmer.fee_deposite_receipt_number_seq', 1, false);


--
-- Name: assign_transport assign_transport_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.assign_transport
    ADD CONSTRAINT assign_transport_pkey PRIMARY KEY (id);


--
-- Name: assignment assignment_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (id);


--
-- Name: assign_subject assignsubject_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.assign_subject
    ADD CONSTRAINT assignsubject_pkey PRIMARY KEY (id);


--
-- Name: attendance_line_item attendance_line_item_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.attendance_line_item
    ADD CONSTRAINT attendance_line_item_pkey PRIMARY KEY (id);


--
-- Name: attendance_master attendance_master_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.attendance_master
    ADD CONSTRAINT attendance_master_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: author author_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.author
    ADD CONSTRAINT author_pkey PRIMARY KEY (id);


--
-- Name: book book_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.book
    ADD CONSTRAINT book_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: class class_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (id);


--
-- Name: class_timing class_timing_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.class_timing
    ADD CONSTRAINT class_timing_pkey PRIMARY KEY (id);


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id);


--
-- Name: deposit deposit_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.deposit
    ADD CONSTRAINT deposit_pkey PRIMARY KEY (id);


--
-- Name: discount_line_items discount_line_items_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.discount_line_items
    ADD CONSTRAINT discount_line_items_pkey PRIMARY KEY (id);


--
-- Name: discount discount_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.discount
    ADD CONSTRAINT discount_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exam_schedule exam_schedule_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_pkey PRIMARY KEY (id);


--
-- Name: exam_title exam_title_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.exam_title
    ADD CONSTRAINT exam_title_pkey PRIMARY KEY (id);


--
-- Name: fare_master fare_master_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fare_master
    ADD CONSTRAINT fare_master_pkey PRIMARY KEY (id);


--
-- Name: fee_deposite fee_deposite_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fee_deposite
    ADD CONSTRAINT fee_deposite_pkey PRIMARY KEY (id);


--
-- Name: fee_head_master fee_head_master_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fee_head_master
    ADD CONSTRAINT fee_head_master_pkey PRIMARY KEY (id);


--
-- Name: fee_installment_line_items fee_installment_line_items_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fee_installment_line_items
    ADD CONSTRAINT fee_installment_line_items_pkey PRIMARY KEY (id);


--
-- Name: fee_master_installment fee_master_line_items_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fee_master_installment
    ADD CONSTRAINT fee_master_line_items_pkey PRIMARY KEY (id);


--
-- Name: fee_master fee_master_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.fee_master
    ADD CONSTRAINT fee_master_pkey PRIMARY KEY (id);


--
-- Name: file file_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.file
    ADD CONSTRAINT file_pkey PRIMARY KEY (id);


--
-- Name: grade_master grade_master_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.grade_master
    ADD CONSTRAINT grade_master_pkey PRIMARY KEY (id);


--
-- Name: issue issue_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.issue
    ADD CONSTRAINT issue_pkey PRIMARY KEY (id);


--
-- Name: language language_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);


--
-- Name: lead lead_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.lead
    ADD CONSTRAINT lead_pkey PRIMARY KEY (id);


--
-- Name: leave leave_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.leave
    ADD CONSTRAINT leave_pkey PRIMARY KEY (id);


--
-- Name: location_master location_master_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.location_master
    ADD CONSTRAINT location_master_pkey PRIMARY KEY (id);


--
-- Name: pending_amount pending_amount_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.pending_amount
    ADD CONSTRAINT pending_amount_pkey PRIMARY KEY (id);


--
-- Name: previous_schooling previous_school_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.previous_schooling
    ADD CONSTRAINT previous_school_pkey PRIMARY KEY (id);


--
-- Name: publisher publisher_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (id);


--
-- Name: purchase purchase_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.purchase
    ADD CONSTRAINT purchase_pkey PRIMARY KEY (id);


--
-- Name: quick_launcher quick_launcher_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.quick_launcher
    ADD CONSTRAINT quick_launcher_pkey PRIMARY KEY (id);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (id);


--
-- Name: route route_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.route
    ADD CONSTRAINT route_pkey PRIMARY KEY (id);


--
-- Name: section section_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: student_fee_installments student_fee_installments_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.student_fee_installments
    ADD CONSTRAINT student_fee_installments_pkey PRIMARY KEY (id);


--
-- Name: student student_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);


--
-- Name: student_addmission studentaddmision_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.student_addmission
    ADD CONSTRAINT studentaddmision_pkey PRIMARY KEY (id);


--
-- Name: subject subject_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (id);


--
-- Name: subject_teacher subjectteacher_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.subject_teacher
    ADD CONSTRAINT subjectteacher_pkey PRIMARY KEY (id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- Name: syllabus syllabus_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.syllabus
    ADD CONSTRAINT syllabus_pkey PRIMARY KEY (id);


--
-- Name: time_slot timeslot_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.time_slot
    ADD CONSTRAINT timeslot_pkey PRIMARY KEY (id);


--
-- Name: timetable timetable_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.timetable
    ADD CONSTRAINT timetable_pkey PRIMARY KEY (id);


--
-- Name: transport transport_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.transport
    ADD CONSTRAINT transport_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (id);


--
-- Name: company_module companymodule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_module
    ADD CONSTRAINT companymodule_pkey PRIMARY KEY (id);


--
-- Name: module module_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);


--
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: role_permission rolepermission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT rolepermission_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_role userrole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT userrole_pkey PRIMARY KEY (id);


--
-- Name: issue issue_status_trigger; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER issue_status_trigger AFTER INSERT OR UPDATE OF status ON dwps_ajmer.issue FOR EACH ROW EXECUTE FUNCTION public.update_book_copies_on_issue_status();


--
-- Name: attendance sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.attendance FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: contact sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.contact FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: file sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.file FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: lead sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.lead FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: leave sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.leave FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: section sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER sync_lastmod BEFORE UPDATE ON dwps_ajmer.section FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: author trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.author FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: book trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.book FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: category trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.category FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: issue trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.issue FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: language trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.language FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: publisher trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.publisher FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: purchase trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.purchase FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: supplier trigger_sync_lastmod; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_sync_lastmod BEFORE UPDATE ON dwps_ajmer.supplier FOR EACH ROW EXECUTE FUNCTION public.sync_lastmod();


--
-- Name: issue trigger_update_book_copies_on_issue; Type: TRIGGER; Schema: dwps_ajmer; Owner: postgres
--

CREATE TRIGGER trigger_update_book_copies_on_issue AFTER INSERT OR DELETE OR UPDATE ON dwps_ajmer.issue FOR EACH ROW EXECUTE FUNCTION public.update_book_copies_on_issue();


--
-- Name: discount discount_fee_head_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.discount
    ADD CONSTRAINT discount_fee_head_id_fkey FOREIGN KEY (fee_head_id) REFERENCES dwps_ajmer.fee_head_master(id);


--
-- Name: discount discount_sessionid_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.discount
    ADD CONSTRAINT discount_sessionid_fkey FOREIGN KEY (sessionid) REFERENCES dwps_ajmer.session(id);


--
-- Name: exam_schedule exam_schedule_Examinor_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT "exam_schedule_Examinor_id_fkey" FOREIGN KEY (examinor_id) REFERENCES dwps_ajmer.contact(id);


--
-- Name: exam_schedule exam_schedule_class_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_class_id_fkey FOREIGN KEY (class_id) REFERENCES dwps_ajmer.class(id);


--
-- Name: exam_schedule exam_schedule_exam_title_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_exam_title_id_fkey FOREIGN KEY (exam_title_id) REFERENCES dwps_ajmer.exam_title(id);


--
-- Name: exam_schedule exam_schedule_subject_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.exam_schedule
    ADD CONSTRAINT exam_schedule_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES dwps_ajmer.subject(id);


--
-- Name: result result_exam_schedule_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.result
    ADD CONSTRAINT result_exam_schedule_id_fkey FOREIGN KEY (exam_schedule_id) REFERENCES dwps_ajmer.exam_schedule(id);


--
-- Name: result result_grade_master_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.result
    ADD CONSTRAINT result_grade_master_id_fkey FOREIGN KEY (grade_master_id) REFERENCES dwps_ajmer.grade_master(id);


--
-- Name: transport transport_driver_id_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.transport
    ADD CONSTRAINT transport_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES dwps_ajmer.contact(id);


--
-- Name: transport transport_end_point_fkey; Type: FK CONSTRAINT; Schema: dwps_ajmer; Owner: postgres
--

ALTER TABLE ONLY dwps_ajmer.transport
    ADD CONSTRAINT transport_end_point_fkey FOREIGN KEY (end_point) REFERENCES dwps_ajmer.location_master(id);


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
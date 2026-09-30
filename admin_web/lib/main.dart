import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

part 'services/admin_auth_service.dart';
part 'pages/login_page.dart';
part 'app/admin_shell.dart';
part 'widgets/admin_shared.dart';
part 'widgets/catalogue_shared.dart';
part 'pages/dashboard_page.dart';
part 'pages/orders_page.dart';
part 'pages/catalogue_page.dart';
part 'pages/partners_page.dart';
part 'pages/invoices_page.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

void main() => runApp(const SnapFooddAdminApp());

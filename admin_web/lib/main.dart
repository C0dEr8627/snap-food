import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'app/admin_shell.dart';
part 'widgets/admin_shared.dart';
part 'pages/dashboard_page.dart';
part 'pages/orders_page.dart';
part 'pages/catalogue_page.dart';
part 'pages/partners_page.dart';
part 'pages/invoices_page.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() => runApp(const SnapFooddAdminApp());

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:clinic_app/core/config/app_config.dart';
import 'package:clinic_app/core/constants/storage_keys.dart';
import 'package:clinic_app/core/services/storage_service.dart';
import 'package:clinic_app/shared/extensions/context_extensions.dart';

void showServerSettingsDialog(BuildContext context) {
  final urlController = TextEditingController(text: AppConfig.baseUrl);
  bool isTesting = false;
  String? testResultMsg;
  bool? testSuccess;

  showDialog(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final colors = context.appColors;

          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.developer_mode_rounded, color: colors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Developer Server Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change the backend API base URL below. Long-press logo or profile card anytime to open this.',
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'http://10.0.0.5:8000',
                      prefixIcon: const Icon(Icons.dns_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (testResultMsg != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: testSuccess == true
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: testSuccess == true ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            testSuccess == true
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: testSuccess == true ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              testResultMsg!,
                              style: TextStyle(
                                color: testSuccess == true ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isTesting
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isTesting = true;
                                    testResultMsg = null;
                                    testSuccess = null;
                                  });

                                  String inputUrl = urlController.text.trim();
                                  if (!inputUrl.startsWith('http://') && !inputUrl.startsWith('https://')) {
                                    inputUrl = 'http://$inputUrl';
                                  }
                                  if (inputUrl.endsWith('/')) {
                                    inputUrl = inputUrl.substring(0, inputUrl.length - 1);
                                  }

                                  try {
                                    final testDio = dio.Dio(dio.BaseOptions(
                                      connectTimeout: const Duration(seconds: 5),
                                      receiveTimeout: const Duration(seconds: 5),
                                    ));
                                    final resp = await testDio.get('$inputUrl/api/doctors');
                                    setDialogState(() {
                                      isTesting = false;
                                      testSuccess = true;
                                      testResultMsg = 'Connected! Server reachable (Status ${resp.statusCode})';
                                    });
                                  } catch (e) {
                                    setDialogState(() {
                                      isTesting = false;
                                      testSuccess = false;
                                      testResultMsg = 'Connection failed: ${e.toString().replaceAll('DioException ', '')}';
                                    });
                                  }
                                },
                          icon: isTesting
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.wifi_find_rounded, size: 18),
                          label: const Text('Test Connection'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final storage = StorageService();
                  await storage.delete(StorageKeys.customBaseUrl);
                  AppConfig.currentBaseUrl = AppConfig.defaultBaseUrl;
                  urlController.text = AppConfig.defaultBaseUrl;
                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reset to default base URL')),
                    );
                  }
                },
                child: const Text('Reset', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  String newUrl = urlController.text.trim();
                  if (newUrl.isEmpty) return;

                  if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
                    newUrl = 'http://$newUrl';
                  }
                  if (newUrl.endsWith('/')) {
                    newUrl = newUrl.substring(0, newUrl.length - 1);
                  }

                  final storage = StorageService();
                  await storage.write(StorageKeys.customBaseUrl, newUrl);
                  AppConfig.currentBaseUrl = newUrl;

                  if (dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Server URL updated to: $newUrl'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Save & Apply', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../beer_view_model.dart';

void showShareModal(BuildContext context, BeerViewModel vm, String productId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Consumer<BeerViewModel>(
        builder: (context, currentVm, _) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  "Pour partager, demande à un(e) ami(e)\nde scanner via son ",
                            ),
                            TextSpan(
                              text: "BeerNotebook",
                              style: const TextStyle(
                                color: Color(0xFF0097A7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: _buildBarcodeContent(currentVm, productId),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: -15,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0097A7),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              106,
                              0,
                              0,
                              0,
                            ).withValues(),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildBarcodeContent(BeerViewModel vm, String productId) {
  if (vm.isGeneratingBarcode) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0097A7)),
    );
  }

  if (vm.barcodeBase64 != null) {
    final String cleanBase64 = vm.barcodeBase64!.split(',').last;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            maxHeight: 140,
          ),
          child: Image.memory(
            base64Decode(cleanBase64),

            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          productId,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  return const Center(
    child: Text(
      "Erreur de génération",
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
  );
}

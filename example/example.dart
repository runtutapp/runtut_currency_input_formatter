import 'package:flutter/material.dart';
import 'package:runtut_currency_input_formatter/runtut_currency_input_formatter.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('runtut_price_formatter')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // IDR: 1.000 (no decimals)
              TextField(
                decoration: const InputDecoration(labelText: 'IDR (1.000)'),
                inputFormatters: [CurrencyInputFormatter()],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // USD: 1,000.99
              TextField(
                decoration: const InputDecoration(labelText: 'USD (1,000.99)'),
                inputFormatters: [
                  CurrencyInputFormatter(locale: 'en_US', currencyCode: 'USD'),
                ],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // EUR: 1.000,99
              TextField(
                decoration: const InputDecoration(labelText: 'EUR (1.000,99)'),
                inputFormatters: [
                  CurrencyInputFormatter(locale: 'de_DE', currencyCode: 'EUR'),
                ],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // JPY: 1,000 (no decimals)
              TextField(
                decoration: const InputDecoration(labelText: 'JPY (1,000)'),
                inputFormatters: [
                  CurrencyInputFormatter(locale: 'ja_JP', currencyCode: 'JPY'),
                ],
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

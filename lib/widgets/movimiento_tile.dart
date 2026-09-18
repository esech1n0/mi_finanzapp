import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import 'package:intl/intl.dart';

/// Widget visual para mostrar un movimiento en una lista.
class MovimientoTile extends StatelessWidget {
  final Movimiento movimiento;
  final VoidCallback? onTap;

  const MovimientoTile({
    super.key,
    required this.movimiento,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final esIngreso = movimiento.tipo == TipoMovimiento.ingreso;
    final colorMonto = esIngreso ? Colors.greenAccent : Colors.redAccent;
    final signo = esIngreso ? '+' : '-';
    final formatoMonto = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Card(
      color: const Color(0xFF2D2040),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3A2E55), width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Ícono de tipo
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (esIngreso ? Colors.green : Colors.red)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  esIngreso
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: colorMonto,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movimiento.descripcion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (movimiento.gastoHormiga)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '🐜',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          movimiento.ubicacion == UbicacionMovimiento.banco
                              ? Icons.account_balance
                              : Icons.payments_outlined,
                          size: 13,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movimiento.ubicacion == UbicacionMovimiento.banco
                              ? 'Banco'
                              : 'Efectivo',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            movimiento.categoria,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd/MM/yy').format(movimiento.fecha),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Monto
              Flexible(
                flex: 0,
                child: Text(
                  '$signo${formatoMonto.format(movimiento.monto)}',
                  style: TextStyle(
                    color: colorMonto,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

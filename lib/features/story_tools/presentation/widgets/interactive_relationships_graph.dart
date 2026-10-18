import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/relationship_layout_utils.dart';
import '../../../characters/domain/models/character.dart';
import '../../domain/models/story_tool_models.dart';

/// Lienzo interactivo para el grafo de relaciones con zoom por rueda de ratón,
/// paneo bidimensional libre, arrastre individual de personajes y guardado de posiciones.
class InteractiveRelationshipsGraph extends StatefulWidget {
  final String projectId;
  final List<Character> characters;
  final List<CharacterRelationship> links;
  final String? selectedCharacterId;
  final String? selectedLinkId;
  final ValueChanged<String?> onSelectCharacter;
  final ValueChanged<String?> onSelectLink;
  final String query;
  final String filter;

  const InteractiveRelationshipsGraph({
    super.key,
    required this.projectId,
    required this.characters,
    required this.links,
    required this.selectedCharacterId,
    required this.selectedLinkId,
    required this.onSelectCharacter,
    required this.onSelectLink,
    required this.query,
    required this.filter,
  });

  @override
  State<InteractiveRelationshipsGraph> createState() =>
      _InteractiveRelationshipsGraphState();
}

class _InteractiveRelationshipsGraphState
    extends State<InteractiveRelationshipsGraph> {
  static const double _canvasWidth = 2400.0;
  static const double _canvasHeight = 1800.0;
  static const Size _canvasSize = Size(_canvasWidth, _canvasHeight);

  late final TransformationController _transformController;
  Map<String, Offset> _positions = {};
  String? _draggingCharacterId;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _centerView();
    _loadSavedPositions();
  }

  @override
  void didUpdateWidget(covariant InteractiveRelationshipsGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      _loadSavedPositions();
    } else {
      _ensurePositionsExist();
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _centerView() {
    // Centrar la vista en el medio del lienzo virtual de 2400x1800
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = context.findRenderObject() as RenderBox?;
      final viewportSize = renderBox?.size ?? const Size(800, 600);
      final dx = -(1200.0 - (viewportSize.width / 2));
      final dy = -(900.0 - (viewportSize.height / 2));
      _transformController.value = Matrix4.translationValues(dx, dy, 0.0);
      setState(() {});
    });
  }

  Future<void> _loadSavedPositions() async {
    final loaded = await RelationshipPositionStore.loadPositions(widget.projectId);
    if (!mounted) return;
    setState(() {
      _positions = loaded;
      _ensurePositionsExist();
    });
  }

  void _ensurePositionsExist() {
    final missing = widget.characters.where((c) => !_positions.containsKey(c.id)).toList();
    if (missing.isNotEmpty) {
      final defaults = calculateDefaultNodePositions(
        widget.characters,
        _canvasSize,
        radiusMultiplier: 0.28,
      );
      for (final c in missing) {
        _positions[c.id] = defaults[c.id] ?? const Offset(1200, 900);
      }
    }
  }

  void _scale(double factor) {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final targetScale = (currentScale * factor).clamp(0.4, 2.8);
    final ratio = targetScale / currentScale;

    _transformController.value = _transformController.value.multiplied(
      Matrix4.diagonal3Values(ratio, ratio, 1.0),
    );
    setState(() {});
  }

  void _resetToCircle() {
    final defaults = calculateDefaultNodePositions(
      widget.characters,
      _canvasSize,
      radiusMultiplier: 0.28,
    );
    setState(() {
      _positions = Map.from(defaults);
    });
    RelationshipPositionStore.savePositions(widget.projectId, _positions);
  }

  @override
  Widget build(BuildContext context) {
    final visibleCharacters = filterCharactersWithConnectedRelationships(
      widget.characters,
      widget.links,
      widget.query,
    );

    final visibleIds = visibleCharacters.map((c) => c.id).toSet();

    final activeLinks = widget.links.where((link) {
      final isNodeVisible =
          visibleIds.contains(link.sourceCharacterId) &&
          visibleIds.contains(link.targetCharacterId);
      return isNodeVisible && matchesRelationFilter(link.relationType, widget.filter);
    }).toList();

    final cleanQuery = normalizeSearchText(widget.query);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.allLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Lienzo navegable interactivo (Pan + Zoom + Rueda)
          Positioned.fill(
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _scale(event.scrollDelta.dy < 0 ? 1.1 : 0.9);
                }
              },
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.4,
                maxScale: 2.8,
                boundaryMargin: const EdgeInsets.all(800),
                constrained: false,
                panEnabled: _draggingCharacterId == null,
                child: SizedBox(
                  width: _canvasWidth,
                  height: _canvasHeight,
                  child: Stack(
                    children: [
                      // Fondo de cuadrícula punteada
                      CustomPaint(
                        size: _canvasSize,
                        painter: _GridBackgroundPainter(),
                      ),

                      // Líneas y etiquetas de relaciones
                      CustomPaint(
                        size: _canvasSize,
                        painter: _RelationshipLinesPainter(
                          links: activeLinks,
                          positions: _positions,
                          selectedLinkId: widget.selectedLinkId,
                        ),
                      ),

                      // Nodos interactivos de personajes
                      ...visibleCharacters.map((character) {
                        final pos = _positions[character.id] ?? const Offset(1200, 900);
                        final isSelected = character.id == widget.selectedCharacterId;
                        final isDirectSearchMatch = cleanQuery.isNotEmpty &&
                            character.searchableNames.any((n) =>
                                normalizeSearchText(n).contains(cleanQuery));

                        return Positioned(
                          left: pos.dx - 36,
                          top: pos.dy - 36,
                          child: GestureDetector(
                            onPanStart: (_) {
                              setState(() {
                                _draggingCharacterId = character.id;
                                widget.onSelectCharacter(character.id);
                              });
                            },
                            onPanUpdate: (details) {
                              final current = _positions[character.id] ?? const Offset(1200, 900);
                              setState(() {
                                _positions[character.id] = current + details.delta;
                              });
                            },
                            onPanEnd: (_) {
                              setState(() {
                                _draggingCharacterId = null;
                              });
                              RelationshipPositionStore.savePositions(
                                widget.projectId,
                                _positions,
                              );
                            },
                            onTap: () {
                              widget.onSelectCharacter(character.id);
                            },
                            child: _CharacterNodeWidget(
                              character: character,
                              isSelected: isSelected,
                              isDirectSearchMatch: isDirectSearchMatch,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Controles de navegación y zoom flotantes
          Positioned(
            left: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Card(
              elevation: 4,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.allMd),
              color: AppColors.surfaceContainerLowest,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _scale(0.85),
                    icon: const Icon(Icons.remove, size: 18),
                    tooltip: 'Alejar',
                  ),
                  ValueListenableBuilder<Matrix4>(
                    valueListenable: _transformController,
                    builder: (context, matrix, _) {
                      final zoomPercent = (matrix.getMaxScaleOnAxis() * 100).round();
                      return Text('$zoomPercent%', style: AppTypography.labelXs);
                    },
                  ),
                  IconButton(
                    onPressed: () => _scale(1.15),
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'Acercar',
                  ),
                  IconButton(
                    onPressed: _centerView,
                    icon: const Icon(Icons.fit_screen_outlined, size: 18),
                    tooltip: 'Centrar vista',
                  ),
                  const VerticalDivider(width: 1),
                  IconButton(
                    onPressed: _resetToCircle,
                    icon: const Icon(Icons.refresh_outlined, size: 18),
                    tooltip: 'Restablecer distribución en círculo',
                  ),
                ],
              ),
            ),
          ),

          // 3. Indicador de ayuda sutil
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
                borderRadius: AppRadii.allSm,
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pan_tool_alt_outlined, size: 13, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Arrastra el fondo para navegar · Rueda para zoom · Arrastra personajes para organizarlos',
                    style: AppTypography.labelXs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterNodeWidget extends StatelessWidget {
  final Character character;
  final bool isSelected;
  final bool isDirectSearchMatch;

  const _CharacterNodeWidget({
    required this.character,
    required this.isSelected,
    required this.isDirectSearchMatch,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isSelected ? 34.0 : 30.0;

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDirectSearchMatch
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerHigh,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDirectSearchMatch ? AppColors.primaryContainer : AppColors.outline),
                width: isSelected ? 3.0 : (isDirectSearchMatch ? 2.5 : 1.5),
              ),
              boxShadow: isSelected || isDirectSearchMatch
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                character.initial,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDirectSearchMatch ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
              borderRadius: AppRadii.allSm,
              border: Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              character.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.labelXs.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (var x = 20.0; x < size.width; x += 32.0) {
      for (var y = 20.0; y < size.height; y += 32.0) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RelationshipLinesPainter extends CustomPainter {
  final List<CharacterRelationship> links;
  final Map<String, Offset> positions;
  final String? selectedLinkId;

  _RelationshipLinesPainter({
    required this.links,
    required this.positions,
    required this.selectedLinkId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final link in links) {
      final from = positions[link.sourceCharacterId];
      final to = positions[link.targetCharacterId];
      if (from == null || to == null) continue;

      final isSelected = link.id == selectedLinkId;
      final color = relationTypeColor(link.relationType);

      final paint = Paint()
        ..color = isSelected ? color : color.withValues(alpha: 0.85)
        ..strokeWidth = isSelected ? 3.5 : 2.0
        ..style = PaintingStyle.stroke;

      if (isTenseRelation(link.relationType)) {
        _drawDashedLine(canvas, from, to, paint);
      } else {
        canvas.drawLine(from, to, paint);
      }

      // Dibujar etiqueta de la relación en el centro
      final midpoint = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);

      final textSpan = TextSpan(
        text: link.relationType,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: color,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: midpoint,
          width: textPainter.width + 12,
          height: textPainter.height + 6,
        ),
        const Radius.circular(4),
      );

      final bgPaint = Paint()..color = AppColors.surfaceContainerLowest;
      final borderPaint = Paint()
        ..color = isSelected ? color : AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 1.5 : 0.5;

      canvas.drawRRect(bgRect, bgPaint);
      canvas.drawRRect(bgRect, borderPaint);

      textPainter.paint(
        canvas,
        midpoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final distance = (end - start).distance;
    if (distance == 0) return;
    final direction = (end - start) / distance;
    for (var offset = 0.0; offset < distance; offset += 12) {
      final from = start + direction * offset;
      final to = start + direction * math.min(offset + 6, distance);
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RelationshipLinesPainter oldDelegate) => true;
}

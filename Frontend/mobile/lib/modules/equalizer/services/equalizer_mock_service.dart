import '../models/eq_preset_model.dart';

class EqualizerMockService {
  static const List<String> bandLabels = [
    '31',
    '62',
    '125',
    '250',
    '500',
    '1K',
    '2K',
    '4K',
    '8K',
    '16K',
  ];

  List<EqPresetModel> getPresets() {
    return const [
      EqPresetModel(
        id: 'warmth',
        name: 'Acoustic Warmth',
        gains: [2, 3, 3, 1.5, 0, -0.5, 0.5, 1.5, 2, 1.5],
      ),
      EqPresetModel(
        id: 'flat',
        name: 'Phẳng',
        gains: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ),
      EqPresetModel(
        id: 'bass',
        name: 'Bass Boost',
        gains: [7, 6, 5, 3, 1, 0, 0, 0, 0, 0],
      ),
      EqPresetModel(
        id: 'treble',
        name: 'Treble Boost',
        gains: [0, 0, 0, 0, 0, 1, 3, 5, 6, 7],
      ),
      EqPresetModel(
        id: 'acoustic',
        name: 'Acoustic',
        gains: [4, 4, 3, 1, 1.5, 1.5, 3, 3.5, 3, 2],
      ),
      EqPresetModel(
        id: 'vocal',
        name: 'Vocal',
        gains: [-2, -3, -3, 1, 4, 4, 3.5, 2, 0, -1],
      ),
      EqPresetModel(
        id: 'rock',
        name: 'Rock',
        gains: [5, 4, 3, 1, -1, -1, 1, 3, 4, 5],
      ),
      EqPresetModel(
        id: 'edm',
        name: 'EDM',
        gains: [6, 5, 2, 0, -2, 1, 0, 2, 5, 6],
      ),
      EqPresetModel(
        id: 'jazz',
        name: 'Jazz',
        gains: [3, 2, 1, 2, -1.5, -1.5, 0, 1.5, 3, 3.5],
      ),
    ];
  }
}

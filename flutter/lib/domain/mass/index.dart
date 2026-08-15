/// Mass guide — Roman Missal Ordinary in three languages.
///
/// Content is split per section (introductory / word / eucharist / concluding)
/// and per variant (penitential / creed / eucharistic) into sibling files.
/// `generateMassSteps(opts)` concatenates them in Missal order, picking the
/// requested variant arrays.
///
/// Mirrors `src/lib/mass/index.ts`.
library;

import 'concluding.dart';
import 'eucharist.dart';
import 'introductory.dart';
import 'types.dart';
import 'word.dart';

export 'concluding.dart';
export 'eucharist.dart';
export 'introductory.dart';
export 'labels.dart';
export 'types.dart';
export 'variants/creed.dart';
export 'variants/eucharistic.dart';
export 'variants/penitential.dart';
export 'word.dart';

List<MassStep> generateMassSteps(MassOptions opts) {
  return [
    ...introductoryRitesSteps(opts),
    ...liturgyOfTheWordSteps(opts),
    ...liturgyOfTheEucharistSteps(opts),
    ...concludingRitesSteps(),
    const MassStep(
      id: 'complete',
      section: MassSection.concluding,
      kind: MassStepKind.complete,
    ),
  ];
}

typedef StepGroup = List<MassStep>;

/// Merges consecutive steps that share a non-null `mergeGroup` into a single
/// group. Steps without a `mergeGroup` form a 1-element group on their own.
List<StepGroup> groupMassSteps(List<MassStep> steps) {
  final groups = <StepGroup>[];
  var i = 0;
  while (i < steps.length) {
    final step = steps[i];
    if (step.mergeGroup != null) {
      final group = <MassStep>[step];
      while (i + 1 < steps.length && steps[i + 1].mergeGroup == step.mergeGroup) {
        i++;
        group.add(steps[i]);
      }
      groups.add(group);
    } else {
      groups.add([step]);
    }
    i++;
  }
  return groups;
}

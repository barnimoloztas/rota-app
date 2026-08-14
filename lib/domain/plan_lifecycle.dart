enum PlanLifecycle {
  draftUntouched,
  draftStudentModified,
  active,
}

extension PlanLifecycleRules on PlanLifecycle {
  /// Whether this plan can still be refreshed before becoming active.
  bool get canRefresh {
    switch (this) {
      case PlanLifecycle.draftUntouched:
      case PlanLifecycle.draftStudentModified:
        return true;

      case PlanLifecycle.active:
        return false;
    }
  }

  /// Whether refresh is allowed to increase the visible task count.
  ///
  /// Untouched drafts can still be re-optimized by the engine,
  /// subject to the normal daily capacity constraints.
  bool get canIncreaseTaskCountDuringRefresh {
    switch (this) {
      case PlanLifecycle.draftUntouched:
        return true;

      case PlanLifecycle.draftStudentModified:
      case PlanLifecycle.active:
        return false;
    }
  }
}
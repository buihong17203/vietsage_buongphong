class HousekeepingRules {
  HousekeepingRules._();

  static const Set<String> completableStatuses = {
    'QUEUED',
    'CLAIMED',
    'IN_PROGRESS',
    'PROCESSING',
  };

  /// Matches exact logic in HousekeepingRules.java
  static bool canComplete(String? roomStatus, String? taskStatus) {
    if (roomStatus != 'PROCESSING') {
      return false;
    }
    if (taskStatus == 'BLOCKED') {
      return false;
    }
    return true;
  }
}

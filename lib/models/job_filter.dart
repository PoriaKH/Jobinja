class FilterOption {
  final String id;
  final String name;

  const FilterOption({
    required this.id,
    required this.name,
  });

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      id: '${json['id']}',
      name: json['name'] ?? '',
    );
  }
}

class JobSkill {
  final String id;
  final String name;

  JobSkill({
    required this.id,
    required this.name,
  });

  factory JobSkill.fromJson(Map<String, dynamic> json) {
    return JobSkill(
      id: '${json['id']}',
      name: json['name'] ?? '',
    );
  }
}

class JobFilter {
  final List<String> keywords;
  final List<String> locations;
  final List<String> jobCategories;
  final List<String> jobTypes;

  final String? salaryMinIndex;
  final String? salaryMinValue;
  final String? workExperience;

  final String sortBy;

  final bool remote;
  final bool internship;
  final bool hasUsd;
  final bool hasMilitaryPlacement;
  final bool hasLoan;
  final bool hasProject;
  final bool hasBonus;
  final bool hasCommission;
  final bool hasOvertimeOffering;
  final bool hasAfternoonShift;
  final bool hasPromotion;
  final bool hasPartTime;
  final bool hasDisabilitySupport;
  final bool hasFlexibleHours;
  final bool hasSupplementaryInsurance;
  final bool hasEsop;
  final bool hasBusinessTrip;

  JobFilter({
    this.keywords = const [],
    this.locations = const [],
    this.jobCategories = const [],
    this.jobTypes = const [],
    this.salaryMinIndex,
    this.salaryMinValue,
    this.workExperience,
    this.sortBy = 'published_at_desc',
    this.remote = false,
    this.internship = false,
    this.hasUsd = false,
    this.hasMilitaryPlacement = false,
    this.hasLoan = false,
    this.hasProject = false,
    this.hasBonus = false,
    this.hasCommission = false,
    this.hasOvertimeOffering = false,
    this.hasAfternoonShift = false,
    this.hasPromotion = false,
    this.hasPartTime = false,
    this.hasDisabilitySupport = false,
    this.hasFlexibleHours = false,
    this.hasSupplementaryInsurance = false,
    this.hasEsop = false,
    this.hasBusinessTrip = false,
  });

  bool get hasFilters {
    return keywords.isNotEmpty ||
        locations.isNotEmpty ||
        jobCategories.isNotEmpty ||
        jobTypes.isNotEmpty ||
        salaryMinValue != null ||
        workExperience != null ||
        remote ||
        internship ||
        hasUsd ||
        hasMilitaryPlacement ||
        hasLoan ||
        hasProject ||
        hasBonus ||
        hasCommission ||
        hasOvertimeOffering ||
        hasAfternoonShift ||
        hasPromotion ||
        hasPartTime ||
        hasDisabilitySupport ||
        hasFlexibleHours ||
        hasSupplementaryInsurance ||
        hasEsop ||
        hasBusinessTrip;
  }

  String toQueryString(int page) {
    final parts = <String>[];

    void add(String key, String value) {
      if (value.isNotEmpty) {
        parts.add('$key=${Uri.encodeQueryComponent(value)}');
      }
    }

    add('page', page.toString());
    add('sort_by', sortBy);

    for (int i = 0; i < keywords.length; i++) {
      add('filters[keywords][$i]', keywords[i]);
    }

    for (int i = 0; i < locations.length; i++) {
      add('filters[locations][$i]', locations[i]);
    }

    for (int i = 0; i < jobCategories.length; i++) {
      add('filters[job_categories][$i]', jobCategories[i]);
    }

    for (int i = 0; i < jobTypes.length; i++) {
      add('filters[job_types][$i]', jobTypes[i]);
    }

    if (salaryMinIndex != null && salaryMinValue != null) {
      add('filters[sal_min][$salaryMinIndex]', salaryMinValue!);
    }

    if (workExperience != null && workExperience!.isNotEmpty) {
      add('filters[w_e][0]', workExperience!);
    }

    void addFlag(String key, bool value) {
      if (value) {
        add('filters[$key]', '1');
      }
    }

    addFlag('remote', remote);
    addFlag('internship', internship);
    addFlag('has_usd', hasUsd);
    addFlag('has_military_placement', hasMilitaryPlacement);
    addFlag('has_loan', hasLoan);
    addFlag('has_project', hasProject);
    addFlag('has_bonus', hasBonus);
    addFlag('has_commission', hasCommission);
    addFlag('has_overtime_offering', hasOvertimeOffering);
    addFlag('has_afternoon_shift', hasAfternoonShift);
    addFlag('has_promotion', hasPromotion);
    addFlag('has_part_time', hasPartTime);
    addFlag('has_disability_support', hasDisabilitySupport);
    addFlag('has_flexible_hours', hasFlexibleHours);
    addFlag('has_supplementary_insurance', hasSupplementaryInsurance);
    addFlag('has_esop', hasEsop);
    addFlag('has_business_trip', hasBusinessTrip);

    return parts.join('&');
  }
}
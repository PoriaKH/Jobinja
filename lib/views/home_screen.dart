import 'package:code/views/profile_screen.dart';
import 'package:flutter/material.dart';

import '../models/job.dart';
import '../models/job_filter.dart';
import '../presenters/job_presenter.dart';
import '../services/api_service.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements JobView {
  late JobPresenter presenter;

  bool isLoading = false;
  String? errorMessage;

  List<Job> jobs = [];
  int currentPage = 1;

  List<FilterOption> categories = [];
  List<FilterOption> provinces = [];
  List<JobSkill> skillSuggestions = [];

  final keywordController = TextEditingController();

  final Set<String> selectedLocations = {};
  final Set<String> selectedCategories = {};
  final Set<String> selectedJobTypes = {};

  String? selectedSalaryIndex;
  String? selectedSalaryValue;
  String? selectedWorkExperience;

  String sortBy = 'published_at_desc';

  bool hasUsd = false;
  bool hasMilitaryPlacement = false;
  bool hasLoan = false;
  bool hasProject = false;
  bool hasBonus = false;
  bool hasCommission = false;
  bool hasOvertimeOffering = false;
  bool hasAfternoonShift = false;
  bool hasPromotion = false;
  bool hasDisabilitySupport = false;
  bool hasFlexibleHours = false;
  bool hasSupplementaryInsurance = false;
  bool hasEsop = false;
  bool hasBusinessTrip = false;

  final jobTypeOptions = const [
    FilterOption(id: 'is_fulltime', name: 'Full-Time'),
    FilterOption(id: 'is_parttime', name: 'Part-Time'),
    FilterOption(id: 'is_internship', name: 'Internship'),
    FilterOption(id: 'is_remote', name: 'Remote'),
  ];

  final workExperienceOptions = const [
    FilterOption(id: 'none', name: 'No experience limit'),
    FilterOption(id: 'under_two', name: 'Less than 3 years'),
    FilterOption(id: 'three_to_six', name: '3 to 6 years'),
    FilterOption(id: 'above_six', name: 'More than 6 years'),
  ];

  final salaryOptions = const [
    FilterOption(id: '0|', name: 'Base salary'),
    FilterOption(id: '1|11000000:', name: 'From 11 million toman'),
    FilterOption(id: '2|15000000:', name: 'From 15 million toman'),
    FilterOption(id: '3|20000000:', name: 'From 20 million toman'),
    FilterOption(id: '4|30000000:', name: 'From 30 million toman'),
    FilterOption(id: '5|40000000:', name: 'From 40 million toman'),
    FilterOption(id: '6|50000000:', name: 'From 50 million toman'),
    FilterOption(id: '7|70000000:', name: 'From 70 million toman'),
    FilterOption(id: '8|100000000:', name: 'From 100 million toman'),
    FilterOption(id: '9|150000000:', name: 'From 150 million toman'),
    FilterOption(id: '10|200000000:', name: 'From 200 million toman'),
    FilterOption(id: '11|300000000:', name: 'From 300 million toman'),
    FilterOption(id: '12|400000000:', name: 'From 400 million toman'),
    FilterOption(id: '13|500000000:', name: 'From 500 million toman'),
    FilterOption(id: '14|negotiable', name: 'Negotiable'),
  ];

  @override
  void initState() {
    super.initState();
    presenter = JobPresenter(this, widget.apiService);
    presenter.loadInitialData();
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void showJobs(List<Job> jobs, int page) {
    setState(() {
      this.jobs = jobs;
      currentPage = page;
      errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      jobs = [];
    });
  }

  @override
  void showFilterOptions(
      List<FilterOption> categories,
      List<FilterOption> provinces,
      ) {
    setState(() {
      this.categories = categories;
      this.provinces = provinces;
    });
  }

  @override
  void showSkillSuggestions(List<JobSkill> skills) {
    setState(() {
      skillSuggestions = skills;
    });
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(apiService: presenter.apiService),
      ),
    );
  }

  void openJob(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailScreen(
          detailUrl: job.detailUrl,
          apiService: presenter.apiService,
        ),
      ),
    );
  }

  Future<void> refreshJobs() async {
    await presenter.refreshCurrentPage();
  }

  JobFilter buildCurrentFilter() {
    final keywords = keywordController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return JobFilter(
      keywords: keywords,
      locations: selectedLocations.toList(),
      jobCategories: selectedCategories.toList(),
      jobTypes: selectedJobTypes.toList(),
      salaryMinIndex: selectedSalaryIndex,
      salaryMinValue: selectedSalaryValue,
      workExperience: selectedWorkExperience,
      sortBy: sortBy,
      hasUsd: hasUsd,
      hasMilitaryPlacement: hasMilitaryPlacement,
      hasLoan: hasLoan,
      hasProject: hasProject,
      hasBonus: hasBonus,
      hasCommission: hasCommission,
      hasOvertimeOffering: hasOvertimeOffering,
      hasAfternoonShift: hasAfternoonShift,
      hasPromotion: hasPromotion,
      hasDisabilitySupport: hasDisabilitySupport,
      hasFlexibleHours: hasFlexibleHours,
      hasSupplementaryInsurance: hasSupplementaryInsurance,
      hasEsop: hasEsop,
      hasBusinessTrip: hasBusinessTrip,
    );
  }

  Future<void> applyFilters() async {
    Navigator.pop(context);
    await presenter.applyFilters(buildCurrentFilter());
  }

  Future<void> clearFilters() async {
    setState(() {
      keywordController.clear();
      selectedLocations.clear();
      selectedCategories.clear();
      selectedJobTypes.clear();
      selectedSalaryIndex = null;
      selectedSalaryValue = null;
      selectedWorkExperience = null;
      sortBy = 'published_at_desc';

      hasUsd = false;
      hasMilitaryPlacement = false;
      hasLoan = false;
      hasProject = false;
      hasBonus = false;
      hasCommission = false;
      hasOvertimeOffering = false;
      hasAfternoonShift = false;
      hasPromotion = false;
      hasDisabilitySupport = false;
      hasFlexibleHours = false;
      hasSupplementaryInsurance = false;
      hasEsop = false;
      hasBusinessTrip = false;
      skillSuggestions = [];
    });

    Navigator.pop(context);
    await presenter.clearFilters();
  }

  Widget buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: currentPage == 1 || isLoading
                  ? null
                  : () => presenter.previousPage(),
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Page $currentPage',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => presenter.nextPage(),
              icon: const Icon(Icons.chevron_right),
              label: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorBody() {
    return RefreshIndicator(
      onRefresh: refreshJobs,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 70, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: refreshJobs,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildJobsBody() {
    return RefreshIndicator(
      onRefresh: refreshJobs,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];

          return JobCard(
            job: job,
            onTap: () => openJob(job),
          );
        },
      ),
    );
  }

  Widget buildBody() {
    if (isLoading && jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return buildErrorBody();
    }

    return buildJobsBody();
  }

  Widget buildFlagSwitch(
      String title,
      bool value,
      void Function(bool) onChanged,
      void Function(VoidCallback) updateBoth,
      ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        updateBoth(() {
          onChanged(newValue);
        });
      },
    );
  }

  void openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateBoth(VoidCallback callback) {
              setState(callback);
              setModalState(() {});
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Search and Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: keywordController,
                      decoration: InputDecoration(
                        labelText: 'Keywords',
                        hintText: 'python, flutter, developer',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            presenter.searchSkills(keywordController.text);
                          },
                        ),
                      ),
                      onSubmitted: presenter.searchSkills,
                    ),

                    if (skillSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text('Skill Suggestions'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skillSuggestions.map((skill) {
                          return ActionChip(
                            label: Text(skill.name),
                            onPressed: () {
                              updateBoth(() {
                                final oldText = keywordController.text.trim();
                                keywordController.text = oldText.isEmpty
                                    ? skill.name
                                    : '$oldText, ${skill.name}';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: sortBy,
                      decoration: const InputDecoration(labelText: 'Sort By'),
                      items: const [
                        DropdownMenuItem(
                          value: 'published_at_desc',
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: 'salary_desc',
                          child: Text('Highest Salary'),
                        ),
                        DropdownMenuItem(
                          value: 'relevance_desc',
                          child: Text('Relevance'),
                        ),
                      ],
                      onChanged: (value) {
                        updateBoth(() {
                          sortBy = value ?? 'published_at_desc';
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text('Job Type',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: jobTypeOptions.map((option) {
                        final selected = selectedJobTypes.contains(option.id);

                        return FilterChip(
                          label: Text(option.name),
                          selected: selected,
                          onSelected: (checked) {
                            updateBoth(() {
                              if (checked) {
                                selectedJobTypes.add(option.id);
                              } else {
                                selectedJobTypes.remove(option.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('Work Experience',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workExperienceOptions.map((option) {
                        final selected = selectedWorkExperience == option.id;

                        return ChoiceChip(
                          label: Text(option.name),
                          selected: selected,
                          onSelected: (_) {
                            updateBoth(() {
                              selectedWorkExperience =
                              selected ? null : option.id;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('Minimum Salary',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: salaryOptions.map((option) {
                        final parts = option.id.split('|');
                        final index = parts[0];
                        final value = parts.length > 1 ? parts[1] : '';

                        final selected = selectedSalaryIndex == index;

                        return ChoiceChip(
                          label: Text(option.name),
                          selected: selected,
                          onSelected: (_) {
                            updateBoth(() {
                              if (selected) {
                                selectedSalaryIndex = null;
                                selectedSalaryValue = null;
                              } else {
                                selectedSalaryIndex = index;
                                selectedSalaryValue = value;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('Locations',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provinces.map((option) {
                        final selected = selectedLocations.contains(option.name);

                        return FilterChip(
                          label: Text(option.name),
                          selected: selected,
                          onSelected: (checked) {
                            updateBoth(() {
                              if (checked) {
                                selectedLocations.add(option.name);
                              } else {
                                selectedLocations.remove(option.name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('Job Categories',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((option) {
                        final selected = selectedCategories.contains(option.id);

                        return FilterChip(
                          label: Text(option.name),
                          selected: selected,
                          onSelected: (checked) {
                            updateBoth(() {
                              if (checked) {
                                selectedCategories.add(option.id);
                              } else {
                                selectedCategories.remove(option.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('Extra Filters',
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    buildFlagSwitch('USD Payment', hasUsd,
                            (v) => hasUsd = v, updateBoth),
                    buildFlagSwitch('Military Placement', hasMilitaryPlacement,
                            (v) => hasMilitaryPlacement = v, updateBoth),
                    buildFlagSwitch(
                        'Loan', hasLoan, (v) => hasLoan = v, updateBoth),
                    buildFlagSwitch('Project Based', hasProject,
                            (v) => hasProject = v, updateBoth),
                    buildFlagSwitch(
                        'Bonus', hasBonus, (v) => hasBonus = v, updateBoth),
                    buildFlagSwitch('Commission', hasCommission,
                            (v) => hasCommission = v, updateBoth),
                    buildFlagSwitch('Overtime', hasOvertimeOffering,
                            (v) => hasOvertimeOffering = v, updateBoth),
                    buildFlagSwitch('Afternoon Shift', hasAfternoonShift,
                            (v) => hasAfternoonShift = v, updateBoth),
                    buildFlagSwitch('Promotion', hasPromotion,
                            (v) => hasPromotion = v, updateBoth),
                    buildFlagSwitch('Disability Support', hasDisabilitySupport,
                            (v) => hasDisabilitySupport = v, updateBoth),
                    buildFlagSwitch('Flexible Hours', hasFlexibleHours,
                            (v) => hasFlexibleHours = v, updateBoth),
                    buildFlagSwitch(
                        'Supplementary Insurance',
                        hasSupplementaryInsurance,
                            (v) => hasSupplementaryInsurance = v,
                        updateBoth),
                    buildFlagSwitch(
                        'ESOP', hasEsop, (v) => hasEsop = v, updateBoth),
                    buildFlagSwitch('Business Trip', hasBusinessTrip,
                            (v) => hasBusinessTrip = v, updateBoth),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: clearFilters,
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: applyFilters,
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterIsActive = presenter.currentFilter.hasFilters;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jobinja Jobs - Page $currentPage'),
        actions: [
          IconButton(
            onPressed: openFilters,
            icon: Icon(
              filterIsActive ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
          ),
          IconButton(
            onPressed: openProfile,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading && jobs.isNotEmpty) const LinearProgressIndicator(),
          if (filterIsActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.blue.withOpacity(0.08),
              child: const Text(
                'Filters are active',
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: buildBody()),
          buildPaginationBar(),
        ],
      ),
    );
  }
}
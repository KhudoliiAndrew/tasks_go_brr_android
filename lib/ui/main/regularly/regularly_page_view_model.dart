import 'dart:async';

import 'package:tasks_go_brr/data/models/tag/tag.dart';
import 'package:tasks_go_brr/data/models/task_regular/task_regular.dart';
import 'package:tasks_go_brr/data/repositories/tags_repository.dart';
import 'package:tasks_go_brr/data/repositories/task_regulalry_repository.dart';
import 'package:tasks_go_brr/utils/time.dart';

class RegularlyPageViewModel {
  TaskRegularRepository _repo = TaskRegularRepository();
  TagsRepository _repoTags = TagsRepository();

  final streamTasks = StreamController<List<TaskRegular>>();
  List<TaskRegular> tasks = [];
  bool showAllTasks = false;

  initRepo(DateTime dateTime) async {
    await _repoTags.initTagsBox();
    await _repo.initTaskBox();

    tasks = _repo.getAllTasks();
    streamTasks.sink.add(tasks);
  }

  Future<void> updateTask(TaskRegular task) async {
    await _repo.updateTask(task);
  }

  Future<void> deleteTask(TaskRegular task) async {
    await _repo.deleteTask(task.id);
  }

  Future<void> deleteTaskForDay(TaskRegular task, DateTime dateTime) async {
    task.statistic[dateTime.millisecondsSinceEpoch.onlyDateInMilli()] = null;
    await updateTask(task);
  }

  Future<void> addCompletedDay(TaskRegular task, DateTime dateTime) async {
    task.statistic[dateTime.millisecondsSinceEpoch.onlyDateInMilli()] = true;
    task.checkList.forEach((element) => element.isCompleted = false);
    await updateTask(task);
  }

  bool isTaskShouldBeShown(TaskRegular task, DateTime currentDate) {
    if(!_repo.isExists(task.id))
      return false;

    if (showAllTasks)
      return showAllTasks;

    return _repo.isTaskShouldBeShown(task, currentDate);
  }

  Tag getTag(String id) =>
      _repoTags.getAllTags().firstWhere((element) => element.id == id);
}
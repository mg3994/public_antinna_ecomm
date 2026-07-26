import 'dart:html';
import 'dart:async';
import '../infrastructure/blogger_data_service.dart';

class SearchAutocompleteRenderer {
  final String inputId;
  final BloggerDataService bloggerService = BloggerDataService();
  DivElement? dropdown;
  int selectedIndex = -1;
  List<String> suggestions = [];
  Timer? debounceTimer;

  SearchAutocompleteRenderer(this.inputId) {
    _init();
  }

  void _init() {
    final input = document.getElementById(inputId) as InputElement?;
    if (input == null) return;

    input.setAttribute('autocomplete', 'off');

    // Create dropdown
    dropdown = DivElement()..className = 'antinna-search-dropdown';

    // Find parent container to position dropdown nicely
    final group = input.closest('.search-input-group') ?? input.parent;
    if (group != null) {
      group.style.setProperty('position', 'relative', 'important');
      group.append(dropdown!);
    }

    input.onInput.listen((_) {
      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 300), () => _handleInput(input.value ?? ''));
    });

    input.onKeyDown.listen(_handleKeydown);

    document.onClick.listen((e) {
      if (input != e.target && dropdown != e.target && dropdown != null && !dropdown!.contains(e.target as Node)) {
        _hide();
      }
    });
  }

  Future<void> _handleInput(String value) async {
    if (value.length < 2) {
      _hide();
      return;
    }

    suggestions = await bloggerService.fetchSearchSuggestions(value);
    _render();
  }

  void _render() {
    if (dropdown == null) return;

    if (suggestions.isEmpty) {
      _hide();
      return;
    }

    dropdown!.text = '';

    for (var i = 0; i < suggestions.length; i++) {
      final s = suggestions[i];
      final item = DivElement()
        ..className = 'antinna-search-item${i == selectedIndex ? ' active' : ''}'
        ..text = s;

      item.onClick.listen((_) => _select(s));
      dropdown!.append(item);
    }

    dropdown!.style.display = 'block';
  }

  void _handleKeydown(KeyboardEvent e) {
    if (dropdown == null || dropdown!.style.display != 'block') return;

    if (e.key == 'ArrowDown') {
      e.preventDefault();
      selectedIndex = (selectedIndex + 1) % suggestions.length;
      _render();
    } else if (e.key == 'ArrowUp') {
      e.preventDefault();
      selectedIndex = (selectedIndex - 1 + suggestions.length) % suggestions.length;
      _render();
    } else if (e.key == 'Enter') {
      if (selectedIndex >= 0) {
        e.preventDefault();
        _select(suggestions[selectedIndex]);
      }
    } else if (e.key == 'Escape') {
      _hide();
    }
  }

  void _select(String val) {
    final input = document.getElementById(inputId) as InputElement?;
    if (input != null) {
      input.value = val;
      _hide();

      // Dispatch submit event to trigger search form execution
      final form = input.form;
      if (form != null) {
        form.dispatchEvent(Event('submit', canBubble: true, cancelable: true));
      }
    }
  }

  void _hide() {
    if (dropdown != null) {
      dropdown!.style.display = 'none';
      selectedIndex = -1;
    }
  }
}

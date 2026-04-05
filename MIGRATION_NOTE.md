# Profile Migration Note

## Breaking Changes
The profile structure has changed from single education/experience to multiple:

### Old Structure:
```dart
'course': string
'university': string
'grade': string  
'year': string
'jobTitle': string
'company': string
'duration': string
'description': string
```

### New Structure:
```dart
'educations': [
  {'course': string, 'university': string, 'grade': string, 'year': string},
  ... (up to 3)
]
'experiences': [
  {'jobTitle': string, 'company': string, 'duration': string, 'description': string},
  ... (up to 5)
]
```

## Migration
Existing users will need to re-enter their profile data or we need a migration script.

## New Optional Fields
- achievements (optional)
- interests (optional)
- references (now optional, was required)

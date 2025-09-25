
Jinja2 Templates: An Educational Lab BookIntroductionWelcome to the world of templating with Jinja2! Jinja2 is a powerful and modern templating engine for Python. It allows you to separate the logic of your application from its presentation, making your code cleaner, more maintainable, and easier to manage.What is a templating engine?Imagine you have a form letter you need to send to 100 different people. The letter's structure is the same for everyone, but details like the name, address, and a specific date change for each person. A templating engine lets you create one "template" of the letter with placeholders (e.g., {{ name }}) and then automatically generate all 100 unique letters by feeding it the specific data for each person.Why use Jinja2?Readability: Jinja2 templates are text files that look very similar to the final output, making them easy to read and write.Power: It includes features like variables, loops, conditional statements, and template inheritance.Security: It has a built-in sandboxed environment to prevent the execution of untrusted code.Wide Adoption: It's used by popular frameworks like Flask and configuration management tools like Ansible.This lab book will guide you through the core concepts of Jinja2 with hands-on exercises. Let's get started!Lab 1: The Basic SyntaxObjectiveUnderstand and use the three fundamental Jinja2 delimiters: {{ ... }}, {% ... %}, and {# ... #}.BackgroundJinja2 syntax revolves around three types of tags:{{ ... }} Expressions: Used to print the value of a variable or the result of an expression to the output.{% ... %} Statements: Used for control flow, such as if conditions, for loops, and template inheritance.{# ... #} Comments: Used for adding comments inside the template that will not be included in the final output.ExerciseCreate a Python script named lab1.py.Create a template file named lab1_template.j2.Write the Python code to render the template with a simple variable.Write the Jinja2 template to use all three delimiters.lab1.pyfrom jinja2 import Environment, FileSystemLoader

# Setup the Jinja2 environment
env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('lab1_template.j2')

# Data to pass to the template
data = {
    'username': 'Alex'
}

# Render the template with the data
output = template.render(data)
print(output)
lab1_template.j2{# This is a comment. It will not appear in the output. #}

{% raw %}Hello, {{ username }}! Welcome to Jinja2.{% endraw %}

{% if username == 'Alex' %}
  Your access level is: Admin.
{% endif %}
Expected OutputHello, Alex! Welcome to Jinja2.

  Your access level is: Admin.
QuestionsWhat would happen if you changed the expression from {{ username }} to {{ user }} in the template without changing the Python script?How would you change the template to greet a user named 'Brenda' differently?Lab 2: Variables and Data StructuresObjectiveLearn how to pass different Python data types (strings, numbers, lists, dictionaries) to a template and access them.BackgroundJinja2 can handle most standard Python data types seamlessly. You can access dictionary keys using dot notation (mydict.key) or square bracket notation (mydict['key']). List items are accessed by index (mylist[0]).ExerciseRender a template that displays details about a network device, which are stored in a Python dictionary.lab2.pyfrom jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('lab2_template.j2')

device_data = {
    'hostname': 'core-router-01',
    'model': 'Cisco CSR1000V',
    'location': 'New York',
    'is_managed': True,
    'interfaces': [
        {'name': 'GigabitEthernet1', 'ip_address': '192.168.1.1'},
        {'name': 'GigabitEthernet2', 'ip_address': '10.10.20.1'},
        {'name': 'Loopback0', 'ip_address': '172.16.0.1'}
    ]
}

output = template.render(device=device_data)
print(output)
lab2_template.j2Device Report
-------------
Hostname: {% raw %}{{ device.hostname }}{% endraw %}
Model: {% raw %}{{ device['model'] }}{% endraw %}
Location: {% raw %}{{ device.location }}{% endraw %}

First Interface Name: {% raw %}{{ device.interfaces[0].name }}{% endraw %}
First Interface IP: {% raw %}{{ device.interfaces[0].ip_address }}{% endraw %}
Expected OutputDevice Report
-------------
Hostname: core-router-01
Model: Cisco CSR1000V
Location: New York

First Interface Name: GigabitEthernet1
First Interface IP: 192.168.1.1
QuestionsHow would you access the IP address of the 'Loopback0' interface?What is the difference between using device.model and device['model']? When might one be better than the other?Lab 3: Control Structures (Loops and Conditionals)ObjectiveUse for loops to iterate over data and if/elif/else statements to add conditional logic to templates.BackgroundFor Loops: The syntax is {% for item in sequence %} ... {% endfor %}. You can iterate over lists, tuples, and dictionary keys.If Statements: The syntax is {% if condition %} ... {% elif other_condition %} ... {% else %} ... {% endif %}. elif and else are optional.ExerciseExpand on the previous lab to generate a full interface configuration list for the network device. Add a condition to highlight the loopback interface.lab3.py(Use the same lab2.py script and device_data)lab3_template.j2hostname {% raw %}{{ device.hostname }}{% endraw %}
!
{% for interface in device.interfaces %}
interface {% raw %}{{ interface.name }}{% endraw %}
  {% if 'Loopback' in interface.name %}
  description ** MANAGEMENT INTERFACE **
  {% else %}
  description Link to something
  {% endif %}
  ip address {% raw %}{{ interface.ip_address }}{% endraw %} 255.255.255.0
  no shutdown
!
{% endfor %}
Expected Outputhostname core-router-01
!
interface GigabitEthernet1
  description Link to something
  ip address 192.168.1.1 255.255.255.0
  no shutdown
!
interface GigabitEthernet2
  description Link to something
  ip address 10.10.20.1 255.255.255.0
  no shutdown
!
interface Loopback0
  description ** MANAGEMENT INTERFACE **
  ip address 172.16.0.1 255.255.255.0
  no shutdown
!
QuestionsHow could you modify the loop to skip configuring the 'GigabitEthernet2' interface entirely?Inside a for loop, Jinja2 provides special variables like loop.index (1-based index) and loop.first. How would you use loop.first to add a special comment only before the first interface?Lab 4: Using FiltersObjectiveModify the presentation of data within a template using Jinja2 filters.BackgroundFilters are applied to variables using the pipe symbol (|). They are essentially functions that transform the data before it's rendered. You can chain filters together.{{ my_string | upper }} -> Renders the string in uppercase.{{ my_list | length }} -> Renders the number of items in the list.{{ my_variable | default('fallback value') }} -> Uses the fallback value if my_variable is not defined.ExerciseCreate a template that formats a user profile, applying filters to ensure consistent capitalization and handle missing data.lab4.pyfrom jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('lab4_template.j2')

# Note: 'country' key is missing
user_profile = {
    'username': 'jdoe',
    'full_name': 'john doe',
    'roles': ['editor', 'viewer', 'contributor']
}

output = template.render(user=user_profile)
print(output)
lab4_template.j2User Profile for: {% raw %}{{ user.username | upper }}{% endraw %}
=================================
Full Name: {% raw %}{{ user.full_name | capitalize }}{% endraw %}
Country: {% raw %}{{ user.country | default('Not Specified') }}{% endraw %}

User has {% raw %}{{ user.roles | length }}{% endraw %} roles.
Roles: {% raw %}{{ user.roles | join(', ') }}{% endraw %}
Expected OutputUser Profile for: JDOE
=================================
Full Name: John doe
Country: Not Specified

User has 3 roles.
Roles: editor, viewer, contributor
QuestionsWhy did capitalize only capitalize the first word in "john doe"? What filter would you use to capitalize every word? (Hint: title)Chain two filters together. How would you get the number of characters in the username?Lab 5: Template InheritanceObjectiveUnderstand how to use template inheritance to create a reusable base layout and reduce code duplication (the DRY principle: Don't Repeat Yourself).BackgroundInheritance allows you to define a base template with common elements and "blocks" that child templates can override.{% block body %}...{% endblock %}: Defines a block in the base template.{% extends "base.html" %}: Used in the child template to specify which base template it's inheriting from. The extends tag must be the very first thing in the child template.ExerciseCreate a base HTML template and two child templates: one for a home page and one for an about page.lab5.pyfrom jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('.'))

# Render the home page
home_template = env.get_template('child_home.html')
home_output = home_template.render(page_title='Home Page')
print("--- HOME PAGE ---")
print(home_output)

# Render the about page
about_template = env.get_template('child_about.html')
about_output = about_template.render(page_title='About Us')
print("\n--- ABOUT PAGE ---")
print(about_output)
base.html<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{% raw %}{{ page_title }}{% endraw %} - My Website</title>
</head>
<body>
    <header>
        <h1>Welcome to My Awesome Website</h1>
        <nav>
            <a href="/home">Home</a> | <a href="/about">About</a>
        </nav>
    </header>
    <main>
        {% block content %}
        <!-- Default content goes here. Child templates will override this. -->
        {% endblock %}
    </main>
    <footer>
        <p>&copy; 2025 My Website</p>
    </footer>
</body>
</html>
child_home.html{% extends "base.html" %}

{% block content %}
    <h2>This is the Home Page</h2>
    <p>Welcome! This content is specific to the home page.</p>
{% endblock %}
child_about.html{% extends "base.html" %}

{% block content %}
    <h2>About Our Company</h2>
    <p>This is where we talk about ourselves.</p>
{% endblock %}
Expected Output(The script will print two separate, complete HTML documents that share the same header, nav, and footer.)QuestionsWhat happens if you don't define a content block in a child template?How would you add a second editable block to the <head> section for page-specific CSS or JavaScript files?

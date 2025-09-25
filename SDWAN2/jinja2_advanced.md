
-----

### **Jinja2 Templates: Lab Book**

**Introduction**

Welcome to the world of templating with Jinja2\! Jinja2 is a powerful and modern templating engine for Python. It allows you to separate the logic of your application from its presentation, making your code cleaner, more maintainable, and easier to manage.

What is a templating engine?

Imagine you have a form letter you need to send to 100 different people. The letter's structure is the same for everyone, but details like the name, address, and a specific date change for each person. A templating engine lets you create one "template" of the letter with placeholders (e.g., `{{ name }}`) and then automatically generate all 100 unique letters by feeding it the specific data for each person.

**Why use Jinja2?**

  - **Readability:** Jinja2 templates are text files that look very similar to the final output, making them easy to read and write.
  - **Power:** It includes features like variables, loops, conditional statements, and template inheritance.
  - **Security:** It has a built-in sandboxed environment to prevent the execution of untrusted code.
  - **Wide Adoption:** It's used by popular frameworks like Flask and configuration management tools like Ansible.

This lab book will guide you through the core concepts of Jinja2 with hands-on exercises. Let's get started\!

-----

### **Lab 1: The Basic Syntax**

**Objective**

Understand and use the three fundamental Jinja2 delimiters: `{{ ... }}`, `{% ... %}`, and `{# ... #}`.

**Background**

Jinja2 syntax revolves around three types of tags:

  - `{{ ... }}` **Expressions:** Used to print the value of a variable or the result of an expression to the output.
  - `{% ... %}` **Statements:** Used for control flow, such as if conditions, for loops, and template inheritance.
  - `{# ... #}` **Comments:** Used for adding comments inside the template that will not be included in the final output.

**Exercise**

1.  Create a Python script named `lab1.py`.
2.  Create a template file named `lab1_template.j2`.
3.  Write the Python code to render the template with a simple variable.
4.  Write the Jinja2 template to use all three delimiters.

**lab1.py**

```python
from jinja2 import Environment, FileSystemLoader

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
```

**lab1\_template.j2**

```jinja
{# This is a comment. It will not appear in the output. #}
Hello, {{ username }}! Welcome to Jinja2.

{% if username == 'Alex' %}
Your access level is: Admin.
{% endif %}
```

**Expected Output**

```text
Hello, Alex! Welcome to Jinja2.

Your access level is: Admin.
```

**Questions**

1.  What would happen if you changed the expression from `{{ username }}` to `{{ user }}` in the template without changing the Python script?
2.  How would you change the template to greet a user named 'Brenda' differently?

-----

### **Lab 2: Variables and Data Structures**

**Objective**

Learn how to pass different Python data types (strings, numbers, lists, dictionaries) to a template and access them.

**Background**

Jinja2 can handle most standard Python data types seamlessly. You can access dictionary keys using dot notation (`mydict.key`) or square bracket notation (`mydict['key']`). List items are accessed by index (`mylist[0]`).

**Exercise**

Render a template that displays details about a network device, which are stored in a Python dictionary.

**lab2.py**

```python
from jinja2 import Environment, FileSystemLoader

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
```

**lab2\_template.j2**

```jinja
Device Report
-------------
Hostname: {{ device.hostname }}
Model: {{ device['model'] }}
Location: {{ device.location }}
First Interface Name: {{ device.interfaces[0].name }}
First Interface IP: {{ device.interfaces[0].ip_address }}
```

**Expected Output**

```text
Device Report
-------------
Hostname: core-router-01
Model: Cisco CSR1000V
Location: New York
First Interface Name: GigabitEthernet1
First Interface IP: 192.168.1.1
```

**Questions**

1.  How would you access the IP address of the 'Loopback0' interface?
2.  What is the difference between using `device.model` and `device['model']`? When might one be better than the other?

-----

### **Lab 3: Control Structures (Loops and Conditionals)**

**Objective**

Use for loops to iterate over data and if/elif/else statements to add conditional logic to templates.

**Background**

  - **For Loops:** The syntax is `{% for item in sequence %} ... {% endfor %}`. You can iterate over lists, tuples, and dictionary keys.
  - **If Statements:** The syntax is `{% if condition %} ... {% elif other_condition %} ... {% else %} ... {% endif %}`. `elif` and `else` are optional.

**Exercise**

Expand on the previous lab to generate a full interface configuration list for the network device. Add a condition to highlight the loopback interface.

**lab3.py**

(Use the same `lab2.py` script and `device_data`)

**lab3\_template.j2**

```jinja
hostname {{ device.hostname }}
!
{% for interface in device.interfaces %}
interface {{ interface.name }}
{% if 'Loopback' in interface.name %}
 description ** MANAGEMENT INTERFACE **
{% else %}
 description Link to something
{% endif %}
 ip address {{ interface.ip_address }} 255.255.255.0
 no shutdown
!
{% endfor %}
```

**Expected Output**

```text
hostname core-router-01
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
```

**Questions**

1.  How could you modify the loop to skip configuring the 'GigabitEthernet2' interface entirely?
2.  Inside a for loop, Jinja2 provides special variables like `loop.index` (1-based index) and `loop.first`. How would you use `loop.first` to add a special comment only before the first interface?

-----

### **Lab 4: Using Filters**

**Objective**

Modify the presentation of data within a template using Jinja2 filters.

**Background**

Filters are applied to variables using the pipe symbol (`|`). They are essentially functions that transform the data before it's rendered. You can chain filters together.

  - `{{ my_string | upper }}` -\> Renders the string in uppercase.
  - `{{ my_list | length }}` -\> Renders the number of items in the list.
  - `{{ my_variable | default('fallback value') }}` -\> Uses the fallback value if `my_variable` is not defined.

**Exercise**

Create a template that formats a user profile, applying filters to ensure consistent capitalization and handle missing data.

**lab4.py**

```python
from jinja2 import Environment, FileSystemLoader

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
```

**lab4\_template.j2**

```jinja
User Profile for: {{ user.username | upper }}
=================================
Full Name: {{ user.full_name | capitalize }}
Country: {{ user.country | default('Not Specified') }}
User has {{ user.roles | length }} roles.
Roles: {{ user.roles | join(', ') }}
```

**Expected Output**

```text
User Profile for: JDOE
=================================
Full Name: John doe
Country: Not Specified
User has 3 roles.
Roles: editor, viewer, contributor
```

**Questions**

1.  Why did `capitalize` only capitalize the first word in "john doe"? What filter would you use to capitalize *every* word? (Hint: `title`)
2.  Chain two filters together. How would you get the number of characters in the username?

-----

### **Lab 5: Template Inheritance**

**Objective**

Understand how to use template inheritance to create a reusable base layout and reduce code duplication (the DRY principle: **D**on't **R**epeat **Y**ourself).

**Background**

Inheritance allows you to define a base template with common elements and "blocks" that child templates can override.

  - `{% block body %}...{% endblock %}:` Defines a block in the base template.
  - `{% extends "base.html" %}:` Used in the child template to specify which base template it's inheriting from. The `extends` tag must be the very first thing in the child template.

**Exercise**

Create a base HTML template and two child templates: one for a home page and one for an about page.

**lab5.py**

```python
from jinja2 import Environment, FileSystemLoader

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
```

**base.html**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ page_title }} - My Website</title>
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
        {% endblock %}
    </main>
    <footer>
        <p>&copy; 2025 My Website</p>
    </footer>
</body>
</html>
```

**child\_home.html**

```jinja
{% extends "base.html" %}

{% block content %}
<h2>This is the Home Page</h2>
<p>Welcome! This content is specific to the home page.</p>
{% endblock %}
```

**child\_about.html**

```jinja
{% extends "base.html" %}

{% block content %}
<h2>About Our Company</h2>
<p>This is where we talk about ourselves.</p>
{% endblock %}
```

**Expected Output**

```text
--- HOME PAGE ---
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Home Page - My Website</title>
</head>
<body>
    <header>
        <h1>Welcome to My Awesome Website</h1>
        <nav>
            <a href="/home">Home</a> | <a href="/about">About</a>
        </nav>
    </header>
    <main>
        
        <h2>This is the Home Page</h2>
        <p>Welcome! This content is specific to the home page.</p>
        
    </main>
    <footer>
        <p>&copy; 2025 My Website</p>
    </footer>
</body>
</html>

--- ABOUT PAGE ---
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>About Us - My Website</title>
</head>
<body>
    <header>
        <h1>Welcome to My Awesome Website</h1>
        <nav>
            <a href="/home">Home</a> | <a href="/about">About</a>
        </nav>
    </header>
    <main>
        
        <h2>About Our Company</h2>
        <p>This is where we talk about ourselves.</p>
        
    </main>
    <footer>
        <p>&copy; 2025 My Website</p>
    </footer>
</body>
</html>
```

**Questions**

1.  What happens if you don't define a content block in a child template?
2.  How would you add a second editable block to the `<head>` section for page-specific CSS or JavaScript files?

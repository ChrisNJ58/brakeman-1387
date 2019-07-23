# Reproducible example for https://github.com/presidentbeef/brakeman/issues/1387

### Background

Brakeman version: 4.5.1
Rails version:  5.0.7.2
Ruby version: 2.4.3

Link to [Rails application code](https://github.com/doliveirakn/brakeman-1387):

### Issue

What problem are you seeing?

If we reference a namespaced ActiveRecord module without it being fully qualified constant, Brakeman will fail to identify it as a model and may report false positives or negatives.

Code:
```ruby
# app/models/document.rb
class Document < ApplicationRecord
  attr_accessor :owner
end

# app/models/namespace/task.rb
module Namespace
  class Task < ApplicationRecord
    attr_accessor :owner
  end
end

# app/controllers/documents_controller.rb
class DocumentsController < ApplicationController
  def index
    redirect_to Document.new(params.permit(:owner)).owner
  end

  def show
    redirect_to Document.find(params[:id])
  end
end

# app/controllers/namespace/tasks_controller.rb
module Namespace
  class TasksController < ApplicationController
    def index
      redirect_to Task.new(params.permit(:owner)).owner
    end

    def show
      redirect_to Task.find(params[:id])
    end
  end
end
```

Running brakeman on this will result in 2 security warnings
```
== Warnings ==

Confidence: High
Category: Redirect
Check: Redirect
Message: Possible unprotected redirect
Code: redirect_to(Document.new(params.permit(:owner)).owner)
File: app/controllers/documents_controller.rb
Line: 4

Confidence: Weak
Category: Redirect
Check: Redirect
Message: Possible unprotected redirect
Code: redirect_to(Task.find(params[:id]))
File: app/controllers/namespace/tasks_controller.rb
Line: 9
```

It appears that brakeman is able to determine that `Document` is an ActiveRecord model but it cannot determine that `Task` is a model. This causes the checks to differ in behaviour and may report false negatives (`Namespace::TasksController#index` should have the same warning as the document one), or false positives (`Namespace::TasksController#show` should not have this warning)

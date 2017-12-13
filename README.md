# POV to Ray

A transpiler from POV file to RAY file.  
POV file format can be found [here](http://wiki.povray.org/content/Reference:Scene_Description_Language).  
Original RAY file format is maybe [here]( https://courses.cs.washington.edu/courses/cse557/08wi/projects/trace/extra/format.html).

## Attention

This program doesn't cover either whole POV file descriptions nor whole RAY file descriptions. This program covers:

- object with #declared mesh2 -> trimesh
- camera -> camera
- light_source (point light) -> point_light
- light_source (parallel) -> directional_light

## Usage

This transpiler is written in ruby, so ruby interpreter is required to use.

You can transpile input.pov into output.ray to execute below:

```
ruby main.rb < input.pov > output.ray
```

If you want to watch lexer's output, exexute below:

```
ruby lexer.test.rb < input.pov > output.lexed.txt
```

## LICENSE

Please see [LICENSE](./LICENSE).

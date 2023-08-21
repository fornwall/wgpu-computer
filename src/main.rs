fn main() {
    let result = pollster::block_on(compute()).expect("Computation failed");
    println!("{result}");
}

pub async fn compute() -> Result<f32, String> {
    let backends = wgpu::util::backend_bits_from_env().unwrap_or(wgpu::Backends::all());
    let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
        backends,
        ..Default::default()
    });
    let adapter: wgpu::Adapter = instance
        .request_adapter(&wgpu::RequestAdapterOptions {
            power_preference: wgpu::PowerPreference::HighPerformance,
            compatible_surface: None,
            force_fallback_adapter: false,
        })
        .await
        .ok_or("request_adapter failed")?;
    let (device, queue) = adapter
        .request_device(
            &wgpu::DeviceDescriptor {
                features: wgpu::Features::empty(),
                limits: wgpu::Limits::default(),
                label: None,
            },
            None,
        )
        .await
        .map_err(|e| format!("request_device failed: {}", e))?;

    let file_name = std::env::args().nth(1).expect("No filename");
    if file_name == "--adapter-info" {
        let info = adapter.get_info();
        println!("Name: {}", info.name);
        println!("Vendor: {}", info.vendor);
        println!("Device: {}", info.device);
        println!("Device type: {:?}", info.device_type);
        println!("Backend: {}", info.backend.to_str());
        println!("Driver: {}", info.driver);
        println!("Driver info: {}", info.driver_info);
        std::process::exit(0);
    }
    let function_src = std::fs::read_to_string(file_name).expect("Cannot read file");
    let entry_point = "_entry_point";

    let source = format!(
        "@group(0) @binding(0) var<storage, read_write> _shader_output: array<f32>;
    @compute @workgroup_size(1) fn {entry_point}(@builtin(global_invocation_id) id: vec3<u32>) {{
      _shader_output[0] = compute();
    }}
    {function_src}"
    );

    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        source: wgpu::ShaderSource::Wgsl(source.into()),
        label: None,
    });

    let work_buffer = device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("work_buffer"),
        size: 4,
        usage: wgpu::BufferUsages::STORAGE
            | wgpu::BufferUsages::COPY_SRC
            | wgpu::BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });

    let result_buffer = device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("result_buffer"),
        size: 4,
        usage: wgpu::BufferUsages::MAP_READ | wgpu::BufferUsages::COPY_DST,
        mapped_at_creation: false,
    });

    let bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
        entries: &[wgpu::BindGroupLayoutEntry {
            binding: 0,
            visibility: wgpu::ShaderStages::COMPUTE,
            ty: wgpu::BindingType::Buffer {
                ty: wgpu::BufferBindingType::Storage { read_only: false },
                has_dynamic_offset: false,
                min_binding_size: None,
            },
            count: None,
        }],
        label: None,
    });

    let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
        label: None,
        layout: &bind_group_layout,
        entries: &[wgpu::BindGroupEntry {
            binding: 0,
            resource: wgpu::BindingResource::Buffer(wgpu::BufferBinding {
                buffer: &work_buffer,
                offset: 0,
                size: None,
            }),
        }],
    });

    let compute_pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: None,
        bind_group_layouts: &[&bind_group_layout],
        push_constant_ranges: &[],
    });

    let compute_pipeline = device.create_compute_pipeline(&wgpu::ComputePipelineDescriptor {
        label: None,
        layout: Some(&compute_pipeline_layout),
        module: &shader,
        entry_point,
    });

    let mut command_encoder =
        device.create_command_encoder(&wgpu::CommandEncoderDescriptor::default());

    let mut pass_encoder =
        command_encoder.begin_compute_pass(&wgpu::ComputePassDescriptor::default());
    pass_encoder.set_pipeline(&compute_pipeline);
    pass_encoder.set_bind_group(0, &bind_group, &[]);
    pass_encoder.dispatch_workgroups(1, 1, 1);
    drop(pass_encoder);

    command_encoder.copy_buffer_to_buffer(&work_buffer, 0, &result_buffer, 0, result_buffer.size());

    queue.submit(std::iter::once(command_encoder.finish()));

    let result_buffer_slice = result_buffer.slice(..);
    result_buffer_slice.map_async(wgpu::MapMode::Read, Result::unwrap);
    instance.poll_all(true);
    let result_buffer_range = result_buffer_slice.get_mapped_range();
    let result_buffer_array: &[f32] = bytemuck::cast_slice(&result_buffer_range);
    return Ok(result_buffer_array[0]);
}

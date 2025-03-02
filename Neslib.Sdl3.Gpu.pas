unit Neslib.Sdl3.Gpu;

{ Simple DirectMedia Layer
  Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org>

  Neslib.Sdl3
  Copyright (C) 2025 Erik van Bilsen

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product d
     ocumentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution. }

{$Include 'Neslib.Sdl3.inc'}

interface

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video;

{$REGION '3D Rendering and GPU Compute'}
/// <summary>
///  The GPU API offers a cross-platform way for apps to talk to modern graphics
///  hardware. It offers both 3D graphics and compute support, in the style of
///  Metal, Vulkan, and Direct3D 12.
///
///  A basic workflow might be something like this:
///
///  The app creates a GPU device with TSdlGpuDevice.Create, and assigns it to
///  a window with TSdlGpuDevice.ClaimWindow--although strictly speaking you
///  can render offscreen entirely, perhaps for image processing, and not use a
///  window at all.
///
///  Next, the app prepares static data (things that are created once and used
///  over and over). For example:
///
///  - Shaders (programs that run on the GPU): use TSdlGpuShader.
///  - Vertex buffers (arrays of geometry data) and other rendering data: use
///    TSdlGpuBuffer and TSdlGpuCopyPass.UploadToBuffer.
///  - Textures (images): use TSdlGpuTexture and TSdlGpuCopyPass.UploadToTexture.
///  - Samplers (how textures should be read from): use TSdlGpuSampler.
///  - Render pipelines (precalculated rendering state): use
///    TSdlGpuGraphicsPipeline.
///
///  To render, the app creates one or more command buffers, with
///  TSdlGpuDevice.AcquireCommandBuffer. Command buffers collect rendering
///  instructions that will be submitted to the GPU in batch. Complex scenes can
///  use multiple command buffers, maybe configured across multiple threads in
///  parallel, as long as they are submitted in the correct order, but many apps
///  will just need one command buffer per frame.
///
///  Rendering can happen to a texture (what other APIs call a "render target")
///  or it can happen to the swapchain texture (which is just a special texture
///  that represents a window's contents). The app can use
///  TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture to render to the window.
///
///  Rendering actually happens in a Render Pass, which is encoded into a
///  command buffer. One can encode multiple render passes (or alternate between
///  render and compute passes) in a single command buffer, but many apps might
///  simply need a single render pass in a single command buffer. Render Passes
///  can render to up to four color textures and one depth texture
///  simultaneously. If the set of textures being rendered to needs to change,
///  the Render Pass must be ended and a new one must be begun.
///
///  The app calls TSdlGpuCommandBuffer.BeginRenderPass. Then it sets states it
///  needs for each draw:
///
///  - TSdlGpuRenderPass.Bind*
///  - TSdlGpuRenderPass.SetViewport
///  - etc
///
///  Then, make the actual draw commands with these states:
///
///  - TSdlGpuRenderPass.DrawPrimitives
///  - TSdlGpuRenderPass.DrawIndexedPrimitives
///  - etc
///
///  After all the drawing commands for a pass are complete, the app should call
///  TSdlGpuRenderPass.Finish. Once a render pass ends all render-related state
///  is reset.
///
///  The app can begin new Render Passes and make new draws in the same command
///  buffer until the entire scene is rendered.
///
///  Once all of the render commands for the scene are complete, the app calls
///  TSdlGpuCommandBuffer.Submit to send it to the GPU for processing.
///
///  If the app needs to read back data from texture or buffers, the API has an
///  efficient way of doing this, provided that the app is willing to tolerate
///  some latency. When the app uses TSdlGpuCopyPass.DownloadFromTexture or
///  TSdlGpuCopyPass.DownloadFromBuffer, submitting the command buffer with
///  TSdlGpuCopyPass.SubmitAndAcquireFence will return a fence handle that the
///  app can poll or wait on in a thread. Once the fence indicates that the
///  command buffer is done processing, it is safe to read the downloaded data.
///  Make sure to call TSdlGpuFence.Release when done with the fence.
///
///  The API also has "compute" support. The app calls
///  TSdlGpuCopyPass.BeginComputePass with compute-writeable textures and/or
///  buffers, which can be written to in a compute shader. Then it sets states
///  it needs for the compute dispatches:
///
///  - TSdlGpuComputePass.BindPipeline
///  - TSdlGpuComputePass.BindStorageBuffers
///  - TSdlGpuComputePass.BindStorageTextures
///
///  Then, dispatch compute work:
///
///  - TSdlGpuComputePass.Dispatch
///
///  For advanced users, this opens up powerful GPU-driven workflows.
///
///  Graphics and compute pipelines require the use of shaders, which as
///  mentioned above are small programs executed on the GPU. Each backend
///  (Vulkan, Metal, D3D12) requires a different shader format. When the app
///  creates the GPU device, the app lets the device know which shader formats
///  the app can provide. It will then select the appropriate backend depending
///  on the available shader formats and the backends available on the platform.
///  When creating shaders, the app must provide the correct shader format for
///  the selected backend. If you would like to learn more about why the API
///  works this way, there is a detailed
///  [blog post](https://moonside.games/posts/layers-all-the-way-down/)
///  explaining this situation.
///
///  It is optimal for apps to pre-compile the shader formats they might use,
///  but for ease of use SDL provides a separate project,
///  [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross),
///  for performing runtime shader cross-compilation. It also has a CLI
///  interface for offline precompilation as well.
///
///  This is an extremely quick overview that leaves out several important
///  details. Already, though, one can see that GPU programming can be quite
///  complex! If you just need simple 2D graphics, the Render API is much easier
///  to use but still hardware-accelerated. That said, even for 2D applications
///  the performance benefits and expressiveness of the GPU API are significant.
///
///  The GPU API targets a feature set with a wide range of hardware support and
///  ease of portability. It is designed so that the app won't have to branch
///  itself by querying feature support. If you need cutting-edge features with
///  limited hardware support, this API is probably not for you.
///
///  Examples demonstrating proper usage of this API can be found
///  [here](https://github.com/TheSpydog/SDL_gpu_examples).
///
///  ## Performance considerations
///
///  Here are some basic tips for maximizing your rendering performance.
///
///  - Beginning a new render pass is relatively expensive. Use as few render
///    passes as you can.
///  - Minimize the amount of state changes. For example, binding a pipeline is
///    relatively cheap, but doing it hundreds of times when you don't need to
///    will slow the performance significantly.
///  - Perform your data uploads as early as possible in the frame.
///  - Don't churn resources. Creating and releasing resources is expensive.
///    It's better to create what you need up front and cache it.
///  - Don't use uniform buffers for large amounts of data (more than a matrix
///    or so). Use a storage buffer instead.
///  - Use cycling correctly. There is a detailed explanation of cycling further
///    below.
///  - Use culling techniques to minimize pixel writes. The less writing the GPU
///    has to do the better. Culling can be a very advanced topic but even
///    simple culling techniques can boost performance significantly.
///
///  In general try to remember the golden rule of performance: doing things is
///  more expensive than not doing things. Don't Touch The Driver!
///
///  ## FAQ
///
///  **Question: When are you adding more advanced features, like ray tracing or
///  mesh shaders?**
///
///  Answer: We don't have immediate plans to add more bleeding-edge features,
///  but we certainly might in the future, when these features prove worthwhile,
///  and reasonable to implement across several platforms and underlying APIs.
///  So while these things are not in the "never" category, they are definitely
///  not "near future" items either.
///
///  **Question: Why is my shader not working?**
///
///  Answer: A common oversight when using shaders is not properly laying out
///  the shader resources/registers correctly. The GPU API is very strict with
///  how it wants resources to be laid out and it's difficult for the API to
///  automatically validate shaders to see if they have a compatible layout. See
///  the documentation for TSdlGpuShader and TSdlGpuComputePipeline for
///  information on the expected layout.
///
///  Another common issue is not setting the correct number of samplers,
///  textures, and buffers in TSdlGpuShaderCreateInfo. If possible use shader
///  reflection to extract the required information from the shader
///  automatically instead of manually filling in the struct's values.
///
///  **Question: My application isn't performing very well. Is this the GPU
///  API's fault?**
///
///  Answer: No. Long answer: The GPU API is a relatively thin layer over the
///  underlying graphics API. While it's possible that we have done something
///  inefficiently, it's very unlikely especially if you are relatively
///  inexperienced with GPU rendering. Please see the performance tips above and
///  make sure you are following them. Additionally, tools like RenderDoc can be
///  very helpful for diagnosing incorrect behavior and performance issues.
///
///  ## System Requirements
///
///  **Vulkan:** Supported on Windows, Linux, Nintendo Switch, and certain
///  Android devices. Requires Vulkan 1.0 with the following extensions and
///  device features:
///
///  - `VK_KHR_swapchain`
///  - `VK_KHR_maintenance1`
///  - `independentBlend`
///  - `imageCubeArray`
///  - `depthClamp`
///  - `shaderClipDistance`
///  - `drawIndirectFirstInstance`
///
///  **D3D12:** Supported on Windows 10 or newer, Xbox One (GDK), and Xbox
///  Series X|S (GDK). Requires a GPU that supports DirectX 12 Feature Level
///  11_1.
///
///  **Metal:** Supported on macOS 10.14+ and iOS/tvOS 13.0+. Hardware
///  requirements vary by operating system:
///
///  - macOS requires an Apple Silicon or
///    [Intel Mac2 family](https://developer.apple.com/documentation/metal/mtlfeatureset/mtlfeatureset_macos_gpufamily2_v1?language=objc)
///    GPU
///  - iOS/tvOS requires an A9 GPU or newer
///  - iOS Simulator and tvOS Simulator are unsupported
///
///  ## Uniform Data
///
///  Uniforms are for passing data to shaders. The uniform data will be constant
///  across all executions of the shader.
///
///  There are 4 available uniform slots per shader stage (where the stages are
///  vertex, fragment, and compute). Uniform data pushed to a slot on a stage
///  keeps its value throughout the command buffer until you call the relevant
///  Push function on that slot again.
///
///  For example, you could write your vertex shaders to read a camera matrix
///  from uniform binding slot 0, push the camera matrix at the start of the
///  command buffer, and that data will be used for every subsequent draw call.
///
///  It is valid to push uniform data during a render or compute pass.
///
///  Uniforms are best for pushing small amounts of data. If you are pushing
///  more than a matrix or two per call you should consider using a storage
///  buffer instead.
///
///  ## A Note On Cycling
///
///  When using a command buffer, operations do not occur immediately - they
///  occur some time after the command buffer is submitted.
///
///  When a resource is used in a pending or active command buffer, it is
///  considered to be "bound". When a resource is no longer used in any pending
///  or active command buffers, it is considered to be "unbound".
///
///  If data resources are bound, it is unspecified when that data will be
///  unbound unless you acquire a fence when submitting the command buffer and
///  wait on it. However, this doesn't mean you need to track resource usage
///  manually.
///
///  All of the functions and structs that involve writing to a resource have a
///  "Cycle" Boolean. TSdlGpuTransferBuffer, TSdlGpuBuffer, and TSdlGpuTexture
///  all effectively function as ring buffers on internal resources. When Cycle
///  is True, if the resource is bound, the cycle rotates to the next unbound
///  internal resource, or if none are available, a new one is created. This
///  means you don't have to worry about complex state tracking and
///  synchronization as long as cycling is correctly employed.
///
///  For example: you can call TSdlGpuDevice.MapTransferBuffer, write texture
///  data, TSdlGpuDevice.UnmapTransferBuffer, and then
///  TSdlCopyPass.UploadToTexture. The next time you write texture data to the
///  transfer buffer, if you set the Cycle param to True, you don't have to
///  worry about overwriting any data that is not yet uploaded.
///
///  Another example: If you are using a texture in a render pass every frame,
///  this can cause a data dependency between frames. If you set cycle to true
///  in the TSdlGpuColorTargetInfo struct, you can prevent this data dependency.
///
///  Cycling will never undefine already bound data. When cycling, all data in
///  the resource is considered to be undefined for subsequent commands until
///  that data is written again. You must take care not to read undefined data.
///
///  Note that when cycling a texture, the entire texture will be cycled, even
///  if only part of the texture is used in the call, so you must consider the
///  entire texture to contain undefined data after cycling.
///
///  You must also take care not to overwrite a section of data that has been
///  referenced in a command without cycling first. It is OK to overwrite
///  unreferenced data in a bound resource without cycling, but overwriting a
///  section of data that has already been referenced will produce unexpected
///  results.
/// </summary>

type
  /// <summary>
  ///  Specifies the primitive topology of a graphics pipeline.
  ///
  ///  If you are using PointList you must include a point size output in the
  ///  vertex shader.
  ///
  ///  - For HLSL compiling to SPIRV you must decorate a float output with
  ///    [[vk::builtin("PointSize")]].
  ///  - For GLSL you must set the gl_PointSize builtin.
  ///  - For MSL you must include a float output with the [[point_size]]
  ///    decorator.
  ///
  ///  Note that sized point topology is totally unsupported on D3D12. Any size
  ///  other than 1 will be ignored. In general, you should avoid using point
  ///  topology for both compatibility and performance reasons. You WILL regret
  ///  using it.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuPrimitiveType = (
    /// <summary>
    ///  A series of separate triangles.
    /// </summary>
    TriangleList  = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,

    /// <summary>
    ///  A series of connected triangles.
    /// </summary>
    TriangleStrip = SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP,

    /// <summary>
    ///  A series of separate lines.
    /// </summary>
    LineList      = SDL_GPU_PRIMITIVETYPE_LINELIST,

    /// <summary>
    ///  A series of connected lines.
    /// </summary>
    LineStrip     = SDL_GPU_PRIMITIVETYPE_LINESTRIP,

    /// <summary>
    ///  A series of separate points.
    /// </summary>
    PointList     = SDL_GPU_PRIMITIVETYPE_POINTLIST);

type
  /// <summary>
  ///  Specifies how the contents of a texture attached to a render pass are
  ///  treated at the beginning of the render pass.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginRenderPass"/>
  TSdlGpuLoadOp = (
    /// <summary>
    ///  The previous contents of the texture will be preserved.
    /// </summary>
    Load     = SDL_GPU_LOADOP_LOAD,

    /// <summary>
    ///  The contents of the texture will be cleared to a color.
    /// </summary>
    Clear    = SDL_GPU_LOADOP_CLEAR,

    /// <summary>
    ///  The previous contents of the texture need not be preserved.
    ///  The contents will be undefined.
    /// </summary>
    DontCare = SDL_GPU_LOADOP_DONT_CARE);

type
  /// <summary>
  ///  Specifies how the contents of a texture attached to a render pass are
  ///  treated at the end of the render pass.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginRenderPass"/>
  TSdlGpuStoreOp = (
    /// <summary>
    ///  The contents generated during the render pass will be written to memory.
    /// </summary>
    Store           = SDL_GPU_STOREOP_STORE,

    /// <summary>
    ///  The contents generated during the render pass are not needed and may be
    ///  discarded. The contents will be undefined.
    /// </summary>
    DontCare        = SDL_GPU_STOREOP_DONT_CARE,

    /// <summary>
    ///  The multisample contents generated during the render pass will be
    ///  resolved to a non-multisample texture. The contents in the multisample
    ///  texture may then be discarded and will be undefined.
    /// </summary>
    Resolve         = SDL_GPU_STOREOP_RESOLVE,

    /// <summary>
    ///  The multisample contents generated during the render pass will be
    ///  resolved to a non-multisample texture. The contents in the multisample
    ///  texture will be written to memory.
    /// </summary>
    ResolveAndStore = SDL_GPU_STOREOP_RESOLVE_AND_STORE);

type
  /// <summary>
  ///  Specifies the size of elements in an index buffer.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  /// <remarks>
  ///  This enum is available since SDL 3.2.0.
  /// </remarks>
  TSdlGpuIndexElementSize = (
    /// <summary>
    ///  The index elements are 16-bit.
    /// </summary>
    Unsigned16Bit = SDL_GPU_INDEXELEMENTSIZE_16BIT,

    /// <summary>
    ///  The index elements are 32-bit.
    /// </summary>
    Unsigned32Bit = SDL_GPU_INDEXELEMENTSIZE_32BIT);

type
  /// <summary>
  ///  Specifies the pixel format of a texture.
  ///
  ///  Texture format support varies depending on driver, hardware, and usage
  ///  flags. In general, you should use TSdlGpuDevice.SupportedTextureFormats
  ///  to query if a format is supported before using it. However, there are a
  ///  few guaranteed formats.
  ///
  ///  For Sampler usage, the following formats are universally supported:
  ///
  ///  - R8G8B8A8UNorm
  ///  - B8G8R8A8UNorm
  ///  - R8UNorm
  ///  - R8SNorm
  ///  - R8G8UNorm
  ///  - R8G8SNorm
  ///  - R8G8B8A8SNorm
  ///  - R16Float
  ///  - R16G16Float
  ///  - R16G16B16A16Float
  ///  - R32Float
  ///  - R32G32Float
  ///  - R32G32B32A32Float
  ///  - R11G11B10Float
  ///  - R8G8B8A8UNormSrgb
  ///  - B8G8R8A8UNormSrgb
  ///  - D16UNorm
  ///
  ///  For ColorTarget usage, the following formats are universally supported:
  ///
  ///  - R8G8B8A8UNorm
  ///  - B8G8R8A8UNorm
  ///  - R8UNorm
  ///  - R16Float
  ///  - R16G16Float
  ///  - R16G16B16A16Float
  ///  - R32Float
  ///  - R32G32Float
  ///  - R32G32B32A32Float
  ///  - R11G11B10Float
  ///  - R8UInt
  ///  - R8G8UInt
  ///  - R8G8B8A8UInt
  ///  - R16UInt
  ///  - R16G16UInt
  ///  - R16G16B16A16UInt
  ///  - R8Int
  ///  - R8G8Int
  ///  - R8G8B8A8Int
  ///  - R16Int
  ///  - R16G16Int
  ///  - R16G16B16A16Int
  ///  - R8G8B8A8UNormSrgb
  ///  - B8G8R8A8UNormSrgb
  ///
  ///  For Storage usages, the following formats are universally supported:
  ///
  ///  - R8G8B8A8UNorm
  ///  - R8G8B8A8SNorm
  ///  - R16G16B16A16Float
  ///  - R32Float
  ///  - R32G32Float
  ///  - R32G32B32A32Float
  ///  - R8G8B8A8UInt
  ///  - R16G16B16A16UInt
  ///  - R8G8B8A8OInt
  ///  - R16G16B16A16Int
  ///
  ///  For DepthStencilTarget usage, the following formats are universally
  ///  supported:
  ///
  ///  - D16UNorm
  ///  - Either (but not necessarily both!) D24UNorm or D32Float
  ///  - Either (but not necessarily both!) D24UNormS8UInt or D32FloatS8UInt
  ///
  ///  Unless D16UNorm is sufficient for your purposes, always check which of
  ///  D24/D32 is supported before creating a depth-stencil texture!
  /// </summary>
  /// <seealso cref="TSdlGpuTexture"/>
  /// <seealso cref="TSdlGpuDevice.TextureSupportsFormat"/>
  TSdlGpuTextureFormat = (
    Invalid            = SDL_GPU_TEXTUREFORMAT_INVALID,

    // Unsigned Normalized Float Color Formats
    A8UNorm            = SDL_GPU_TEXTUREFORMAT_A8_UNORM,
    R8UNorm            = SDL_GPU_TEXTUREFORMAT_R8_UNORM,
    R8G8UNorm          = SDL_GPU_TEXTUREFORMAT_R8G8_UNORM,
    R8G8B8A8UNorm      = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    R16UNorm           = SDL_GPU_TEXTUREFORMAT_R16_UNORM,
    R16G16UNorm        = SDL_GPU_TEXTUREFORMAT_R16G16_UNORM,
    R16G16B16A16UNorm  = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UNORM,
    R10G10B10A2UNorm   = SDL_GPU_TEXTUREFORMAT_R10G10B10A2_UNORM,
    B5G6R5UNorm        = SDL_GPU_TEXTUREFORMAT_B5G6R5_UNORM,
    B5G5R5A1UNorm      = SDL_GPU_TEXTUREFORMAT_B5G5R5A1_UNORM,
    B4G4R4A4UNorm      = SDL_GPU_TEXTUREFORMAT_B4G4R4A4_UNORM,
    B8G8R8A8UNorm      = SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM,

    // Compressed Unsigned Normalized Float Color Formats
    BC1RgbaUNorm       = SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM,
    BC2RgbaUNorm       = SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM,
    BC3RgbaUNorm       = SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM,
    BC4RUNorm          = SDL_GPU_TEXTUREFORMAT_BC4_R_UNORM,
    BC5RGUNorm         = SDL_GPU_TEXTUREFORMAT_BC5_RG_UNORM,
    BC7RgbaUNorm       = SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM,

    // Compressed Signed Float Color Formats
    BC6HRgbFloat       = SDL_GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT,

    // Compressed Unsigned Float Color Formats
    BC6HRgbUFloat      = SDL_GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT,

    // Signed Normalized Float Color Formats
    R8SNorm            = SDL_GPU_TEXTUREFORMAT_R8_SNORM,
    R8G8SNorm          = SDL_GPU_TEXTUREFORMAT_R8G8_SNORM,
    R8G8B8A8SNorm      = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_SNORM,
    R16SNorm           = SDL_GPU_TEXTUREFORMAT_R16_SNORM,
    R16G16SNorm        = SDL_GPU_TEXTUREFORMAT_R16G16_SNORM,
    R16G16B16A16SNorm  = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_SNORM,

    // Signed Float Color Formats
    R16Float           = SDL_GPU_TEXTUREFORMAT_R16_FLOAT,
    R16G16Float        = SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT,
    R16G16B16A16Float  = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT,
    R32Float           = SDL_GPU_TEXTUREFORMAT_R32_FLOAT,
    R32G32Float        = SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT,
    R32G32B32A32Float  = SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT,

    // Unsigned Float Color Formats
    R11G11B10UFloat    = SDL_GPU_TEXTUREFORMAT_R11G11B10_UFLOAT,

    // Unsigned Integer Color Formats
    R8UInt             = SDL_GPU_TEXTUREFORMAT_R8_UINT,
    R8G8UInt           = SDL_GPU_TEXTUREFORMAT_R8G8_UINT,
    R8G8B8A8UInt       = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UINT,
    R16UInt            = SDL_GPU_TEXTUREFORMAT_R16_UINT,
    R16G16UInt         = SDL_GPU_TEXTUREFORMAT_R16G16_UINT,
    R16G16B16A16UInt   = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UINT,
    R32UInt            = SDL_GPU_TEXTUREFORMAT_R32_UINT,
    R32G32UInt         = SDL_GPU_TEXTUREFORMAT_R32G32_UINT,
    R32G32B32A32UInt   = SDL_GPU_TEXTUREFORMAT_R32G32B32A32_UINT,

    // Signed Integer Color Formats
    R8Int              = SDL_GPU_TEXTUREFORMAT_R8_INT,
    R8G8Int            = SDL_GPU_TEXTUREFORMAT_R8G8_INT,
    R8G8B8A8Int        = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_INT,
    R16Int             = SDL_GPU_TEXTUREFORMAT_R16_INT,
    R16G16Int          = SDL_GPU_TEXTUREFORMAT_R16G16_INT,
    R16G16B16A16Int    = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_INT,
    R32Int             = SDL_GPU_TEXTUREFORMAT_R32_INT,
    R32G32Int          = SDL_GPU_TEXTUREFORMAT_R32G32_INT,
    R32G32B32A32Int    = SDL_GPU_TEXTUREFORMAT_R32G32B32A32_INT,

    // SRGB Unsigned Normalized Color Formats
    R8G8B8A8UNormSrgb  = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB,
    B8G8R8A8UNormSrgb  = SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB,

    // Compressed SRGB Unsigned Normalized Color Formats
    BC1RgbaUNormSrgb   = SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB,
    BC2RgbaUNormSrgb   = SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB,
    BC3RgbaUNormSrgb   = SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB,
    BC7RgbaUNormSrgb   = SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB,

    // Depth Formats
    D16UNorm           = SDL_GPU_TEXTUREFORMAT_D16_UNORM,
    D24UNorm           = SDL_GPU_TEXTUREFORMAT_D24_UNORM,
    D32Float           = SDL_GPU_TEXTUREFORMAT_D32_FLOAT,
    D24UNormS8UInt     = SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
    D32FloatS8UInt     = SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT,

    // Compressed ASTC Normalized Float Color Formats
    Astc4x4UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM,
    Astc5x4UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM,
    Astc5x5UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM,
    Astc6x5UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM,
    Astc6x6UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM,
    Astc8x5UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM,
    Astc8x6UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM,
    Astc8x8UNorm       = SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM,
    Astc10x5UNorm      = SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM,
    Astc10x6UNorm      = SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM,
    Astc10x8UNorm      = SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM,
    Astc10x10UNorm     = SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM,
    Astc12x10UNorm     = SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM,
    Astc12x12UNorm     = SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM,

    // Compressed SRGB ASTC Normalized Float Color Formats
    Astc4x4UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB,
    Astc5x4UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB,
    Astc5x5UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB,
    Astc6x5UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB,
    Astc6x6UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB,
    Astc8x5UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB,
    Astc8x6UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB,
    Astc8x8UNormSrgb   = SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB,
    Astc10x5UNormSrgb  = SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB,
    Astc10x6UNormSrgb  = SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB,
    Astc10x8UNormSrgb  = SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB,
    Astc10x10UNormSrgb = SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB,
    Astc12x10UNormSrgb = SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB,
    Astc12x12UNormSrgb = SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB,

    // Compressed ASTC Signed Float Color Formats
    Astc4x4Float       = SDL_GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT,
    Astc5x4Float       = SDL_GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT,
    Astc5x5Float       = SDL_GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT,
    Astc6x5Float       = SDL_GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT,
    Astc6x6Float       = SDL_GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT,
    Astc8x5Float       = SDL_GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT,
    Astc8x6Float       = SDL_GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT,
    Astc8x8Float       = SDL_GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT,
    Astc10x5Float      = SDL_GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT,
    Astc10x6Float      = SDL_GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT,
    Astc10x8Float      = SDL_GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT,
    Astc10x10Float     = SDL_GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT,
    Astc12x10Float     = SDL_GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT,
    Astc12x12Float     = SDL_GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT);

type
  _TSdlGpuTextureFormatHelper = record helper for TSdlGpuTextureFormat
  {$REGION 'Internal Declarations'}
  private
    function GetTexelBlockSize: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Calculate the size in bytes of a texture format with dimensions.
    /// </summary>
    /// <param name="AWidth">Width in pixels.</param>
    /// <param name="AHeight">Height in pixels.</param>
    /// <param name="ADepthOrLayerCount">Depth for 3D textures or layer count otherwise.</param>
    /// <returns>The size of a texture with this format and dimensions.</returns>
    function CalculateSize(const AWidth, AHeight, ADepthOrLayerCount: Integer): Integer; inline;

    /// <summary>
    ///  The texel block size for the texture format.
    /// </summary>
    /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
    property TexelBlockSize: Integer read GetTexelBlockSize;
  end;

type
  /// <summary>
  ///  Specifies how a texture is intended to be used by the client.
  ///
  ///  A texture must have at least one usage flag. Note that some usage flag
  ///  combinations are invalid.
  ///
  ///  With regards to compute storage usage, [Read, Write] means that you can
  ///  have shader A that only writes into the texture and shader B that only
  ///  reads from the texture and bind the same texture to either shader
  ///  respectively. Simultaneous means that you can do reads and writes within
  ///  the same shader or compute pass. It also implies that atomic ops can be
  ///  used, since those are read-modify-write operations. If you use
  ///  Simultaneous, you are responsible for avoiding data races, as there is no
  ///  data synchronization within a compute pass. Note that Simultaneous usage
  ///  is only supported by a limited number of texture formats.
  /// </summary>
  /// <seealso cref="TSdlGpuTexture"/>
  TSdlGpuTextureUsageFlag = (
    // Texture supports sampling.
    Sampler                             = 0,

    // Texture is a color render target.
    ColorTarget                         = 1,

    // Texture is a depth stencil target.
    DepthStencilTarget                  = 2,

    // Texture supports storage reads in graphics stages.
    GraphicsStorageRead                 = 3,

    // Texture supports storage reads in the compute stage.
    ComputeStorageRead                  = 4,

    // Texture supports storage writes in the compute stage.
    ComputeStorageWrite                 = 5,

    // Texture supports reads and writes in the same compute shader.
    // This is NOT equivalent to [Read, Write].
    ComputeStorageSimultaneousReadWrite = 6);
  TSdlGpuTextureUsageFlags = set of TSdlGpuTextureUsageFlag;

type
  /// <summary>
  ///  Specifies the type of a texture.
  /// </summary>
  /// <seealso cref="TSdlGpuTexture"/>
  TSdlGpuTextureKind = (
    /// <summary>
    ///  The texture is a 2-dimensional image.
    /// </summary>
    TwoD      = SDL_GPU_TEXTURETYPE_2D,

    /// <summary>
    ///  The texture is a 2-dimensional array image.
    /// </summary>
    TwoDArray = SDL_GPU_TEXTURETYPE_2D_ARRAY,

    /// <summary>
    ///  The texture is a 3-dimensional image.
    /// </summary>
    ThreeD    = SDL_GPU_TEXTURETYPE_3D,

    /// <summary>
    ///  The texture is a cube image.
    /// </summary>
    Cube      = SDL_GPU_TEXTURETYPE_CUBE,

    /// <summary>
    ///  The texture is a cube array image.
    /// </summary>
    CubeArray = SDL_GPU_TEXTURETYPE_CUBE_ARRAY);

type
  /// <summary>
  ///  Specifies the sample count of a texture.
  ///
  ///  Used in multisampling. Note that this value only applies when the texture
  ///  is used as a render target.
  /// </summary>
  /// <seealso cref="TSdlGpuTexture"/>
  /// <seealso cref="TSdlGpuDevice.TextureSupportsSampleCount"/>
  TSdlGpuSampleCount = (
    /// <summary>
    ///  No multisampling.
    /// </summary>
    One   = SDL_GPU_SAMPLECOUNT_1,

    /// <summary>
    ///  MSAA 2x
    /// </summary>
    Two   = SDL_GPU_SAMPLECOUNT_2,

    /// <summary>
    ///  MSAA 4x
    /// </summary>
    Four  = SDL_GPU_SAMPLECOUNT_4,

    /// <summary>
    ///  MSAA 8x
    /// </summary>
    Eight = SDL_GPU_SAMPLECOUNT_8);

type
  /// <summary>
  ///  Specifies the face of a cube map.
  ///
  ///  Can be passed in as the layer field in texture-related structs.
  /// </summary>
  TSdlGpuCubeMapFace = (
    PositiveX = SDL_GPU_CUBEMAPFACE_POSITIVEX,
    NegativeX = SDL_GPU_CUBEMAPFACE_NEGATIVEX,
    PositiveY = SDL_GPU_CUBEMAPFACE_POSITIVEY,
    NegativeY = SDL_GPU_CUBEMAPFACE_NEGATIVEY,
    PositiveZ = SDL_GPU_CUBEMAPFACE_POSITIVEZ,
    NegativeZ = SDL_GPU_CUBEMAPFACE_NEGATIVEZ);

type
  /// <summary>
  ///  Specifies how a buffer is intended to be used by the client.
  ///
  ///  A buffer must have at least one usage flag. Note that some usage flag
  ///  combinations are invalid.
  ///
  ///  Unlike textures, [Read, Write] can be used for simultaneous read-write
  ///  usage. The same data synchronization concerns as textures apply.
  ///
  ///  If you use a Storage flag, the data in the buffer must respect std140
  ///  layout conventions. In practical terms this means you must ensure that
  ///  vec3 and vec4 fields are 16-byte aligned.
  /// </summary>
  /// <seealso cref="TSdlGpuBuffer"/>
  TSdlGpuBufferUsageFlag = (
    // Buffer is a vertex buffer.
    Vertex              = 0,

    // Buffer is an index buffer.
    Index               = 1,

    // Buffer is an indirect buffer.
    Indirect            = 2,

    // Buffer supports storage reads in graphics stages.
    GraphicsStorageRead = 3,

    // Buffer supports storage reads in the compute stage.
    ComputeStorageRead  = 4,

    // Buffer supports storage writes in the compute stage.
    ComputeStorageWrite = 5);
  TSdlGpuBufferUsageFlags = set of TSdlGpuBufferUsageFlag;

type
  /// <summary>
  ///  Specifies how a transfer buffer is intended to be used by the client.
  ///
  ///  Note that mapping and copying FROM an upload transfer buffer or TO a
  ///  download transfer buffer is undefined behavior.
  /// </summary>
  /// <seealso cref="TSdlGpuTransferBuffer"/>
  TSdlGpuTransferBufferUsage = (
    Upload   = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
    Download = SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD);

type
  /// <summary>
  ///  Specifies which stage a shader program corresponds to.
  /// </summary>
  /// <seealso cref="TSdlGpuShader"/>
  TSdlGpuShaderStage = (
    Vertex   = SDL_GPU_SHADERSTAGE_VERTEX,
    Fragment = SDL_GPU_SHADERSTAGE_FRAGMENT);

type
  /// <summary>
  ///  Specifies the format of shader code.
  ///
  ///  Each format corresponds to a specific backend that accepts it.
  /// </summary>
  /// <seealso cref="TSdlGpuShader"/>
  TSdlGpuShaderFormat = (
    // Shaders for NDA'd platforms.
    &Private = 0,

    // SPIR-V shaders for Vulkan.
    SpirV    = 1,

    // DXBC SM5_1 shaders for D3D12.
    Dxbc     = 2,

    // DXIL SM6_0 shaders for D3D12.
    Dxil     = 3,

    // MSL shaders for Metal.
    Msl      = 4,

    // Precompiled metallib shaders for Metal.
    MetalLib = 5);
  TSdlGpuShaderFormats = set of TSdlGpuShaderFormat;

type
  /// <summary>
  ///  Specifies the format of a vertex attribute.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuVertexElementFormat = (
    Invalid     = SDL_GPU_VERTEXELEMENTFORMAT_INVALID,

    // 32-bit Signed Integers
    Int         = SDL_GPU_VERTEXELEMENTFORMAT_INT,
    Int2        = SDL_GPU_VERTEXELEMENTFORMAT_INT2,
    Int3        = SDL_GPU_VERTEXELEMENTFORMAT_INT3,
    Int4        = SDL_GPU_VERTEXELEMENTFORMAT_INT4,

    // 32-bit Unsigned Integers
    UInt        = SDL_GPU_VERTEXELEMENTFORMAT_UINT,
    UInt2       = SDL_GPU_VERTEXELEMENTFORMAT_UINT2,
    UInt3       = SDL_GPU_VERTEXELEMENTFORMAT_UINT3,
    UInt4       = SDL_GPU_VERTEXELEMENTFORMAT_UINT4,

    // 32-bit Floats
    Float       = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT,
    Float2      = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2,
    Float3      = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
    Float4      = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4,

    // 8-bit Signed Integers
    Byte2       = SDL_GPU_VERTEXELEMENTFORMAT_BYTE2,
    Byte4       = SDL_GPU_VERTEXELEMENTFORMAT_BYTE4,

    // 8-bit Unsigned Integers
    UByte2      = SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2,
    UByte4      = SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4,

    // 8-bit Signed Normalized
    Byte2Norm   = SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM,
    Byte4Norm   = SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM,

    // 8-bit Unsigned Normalized
    UByte2Norm  = SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM,
    UByte4Norm  = SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM,

    // 16-bit Signed Integers
    Short2      = SDL_GPU_VERTEXELEMENTFORMAT_SHORT2,
    Short4      = SDL_GPU_VERTEXELEMENTFORMAT_SHORT4,

    // 16-bit Unsigned Integers
    UShort2     = SDL_GPU_VERTEXELEMENTFORMAT_USHORT2,
    UShort4     = SDL_GPU_VERTEXELEMENTFORMAT_USHORT4,

    // 16-bit Signed Normalized
    Short2Norm  = SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM,
    Short4Norm  = SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM,

    // 16-bit Unsigned Normalized
    UShort2Norm = SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM,
    UShort4Norm = SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM,

    // 16-bit Floats
    Half2       = SDL_GPU_VERTEXELEMENTFORMAT_HALF2,
    Half4       = SDL_GPU_VERTEXELEMENTFORMAT_HALF4);

type
  /// <summary>
  ///  Specifies the rate at which vertex attributes are pulled from buffers.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuVertexInputRate = (
    /// <summary>
    ///  Attribute addressing is a function of the vertex index.
    /// </summary>
    Vertex  = SDL_GPU_VERTEXINPUTRATE_VERTEX,

    /// <summary>
    ///  Attribute addressing is a function of the instance index.
    /// </summary>
    Intance = SDL_GPU_VERTEXINPUTRATE_INSTANCE);

type
  /// <summary>
  ///  Specifies the fill mode of the graphics pipeline.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuFillMode = (
    /// <summary>
    ///  Polygons will be rendered via rasterization.
    /// </summary>
    Fill = SDL_GPU_FILLMODE_FILL,

    /// <summary>
    ///  Polygon edges will be drawn as line segments.
    /// </summary>
    Line = SDL_GPU_FILLMODE_LINE);

type
  /// <summary>
  ///  Specifies the facing direction in which triangle faces will be culled.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuCullMode = (
    /// <summary>
    ///  No triangles are culled.
    /// </summary>
    None  = SDL_GPU_CULLMODE_NONE,

    /// <summary>
    ///  Front-facing triangles are culled.
    /// </summary>
    Front = SDL_GPU_CULLMODE_FRONT,

    /// <summary>
    ///  Back-facing triangles are culled.
    /// </summary>
    Back  = SDL_GPU_CULLMODE_BACK);

type
  /// <summary>
  ///  Specifies the vertex winding that will cause a triangle to be determined to
  ///  be front-facing.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuFrontFace = (
    /// <summary>
    ///  A triangle with counter-clockwise vertex winding will be considered front-facing.
    /// </summary>
    CounterClockwise = SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE,

    /// <summary>
    ///  A triangle with clockwise vertex winding will be considered front-facing.
    /// </summary>
    Clockwise        = SDL_GPU_FRONTFACE_CLOCKWISE);

type
  /// <summary>
  ///  Specifies a comparison operator for depth, stencil and sampler operations.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuCompareOp = (
    Invalid        = SDL_GPU_COMPAREOP_INVALID,

    /// <summary>
    ///  The comparison always evaluates false.
    /// </summary>
    Never          = SDL_GPU_COMPAREOP_NEVER,

    /// <summary>
    ///  The comparison evaluates reference < test.
    /// </summary>
    Less           = SDL_GPU_COMPAREOP_LESS,

    /// <summary>
    ///  The comparison evaluates reference = test.
    /// </summary>
    Equal          = SDL_GPU_COMPAREOP_EQUAL,

    /// <summary>
    ///  The comparison evaluates reference <= test.
    /// </summary>
    LessOrEqual    = SDL_GPU_COMPAREOP_LESS_OR_EQUAL,

    /// <summary>
    ///  The comparison evaluates reference > test.
    /// </summary>
    Greater        = SDL_GPU_COMPAREOP_GREATER,

    /// <summary>
    ///  The comparison evaluates reference <> test.
    /// </summary>
    NotEqual       = SDL_GPU_COMPAREOP_NOT_EQUAL,

    /// <summary>
    ///  The comparison evalutes reference >= test.
    /// </summary>
    GreaterOrEqual = SDL_GPU_COMPAREOP_GREATER_OR_EQUAL,

    /// <summary>
    ///  The comparison always evaluates true.
    /// </summary>
    Always         = SDL_GPU_COMPAREOP_ALWAYS);

type
  /// <summary>
  ///  Specifies what happens to a stored stencil value if stencil tests fail or
  ///  pass.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuStencilOp = (
    Invalid           = SDL_GPU_STENCILOP_INVALID,

    /// <summary>
    ///  Keeps the current value.
    /// </summary>
    Keep              = SDL_GPU_STENCILOP_KEEP,

    /// <summary>
    ///  Sets the value to 0.
    /// </summary>
    Zero              = SDL_GPU_STENCILOP_ZERO,

    /// <summary>
    ///  Sets the value to reference.
    /// </summary>
    Replace           = SDL_GPU_STENCILOP_REPLACE,

    /// <summary>
    ///  Increments the current value and clamps to the maximum value.
    /// </summary>
    IncrementAndClamp = SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP,

    /// <summary>
    ///  Decrements the current value and clamps to 0.
    /// </summary>
    DecrementAndClamp = SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP,

    /// <summary>
    ///  Bitwise-inverts the current value.
    /// </summary>
    Invert            = SDL_GPU_STENCILOP_INVERT,

    /// <summary>
    ///  Increments the current value and wraps back to 0.
    /// </summary>
    IncrementAndWrap  = SDL_GPU_STENCILOP_INCREMENT_AND_WRAP,

    /// <summary>
    ///  Decrements the current value and wraps to the maximum value.
    /// </summary>
    DecrementAndWrap  = SDL_GPU_STENCILOP_DECREMENT_AND_WRAP);

type
  /// <summary>
  ///  Specifies the operator to be used when pixels in a render target are
  ///  blended with existing pixels in the texture.
  ///
  ///  The source color is the value written by the fragment shader. The
  ///  destination color is the value currently existing in the texture.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuBlendOp = (
    Invalid         = SDL_GPU_BLENDOP_INVALID,

    /// <summary>
    ///  (Source * SourceFactor) + (Destination * DestinationFactor)
    /// </summary>
    Add             = SDL_GPU_BLENDOP_ADD,

    /// <summary>
    ///  (Source * SourceFactor) - (Destination * DestinationFactor)
    /// </summary>
    Subtract        = SDL_GPU_BLENDOP_SUBTRACT,

    /// <summary>
    ///  (Destination * DestinationFactor) - (Source * SourceFactor)
    /// </summary>
    ReverseSubtract = SDL_GPU_BLENDOP_REVERSE_SUBTRACT,

    /// <summary>
    ///  Min(Source, Destination)
    /// </summary>
    Min             = SDL_GPU_BLENDOP_MIN,

    /// <summary>
    ///  Max(Source, Destination)
    /// </summary>
    Max             = SDL_GPU_BLENDOP_MAX);

type
  /// <summary>
  ///  Specifies a blending factor to be used when pixels in a render target are
  ///  blended with existing pixels in the texture.
  ///
  ///  The source color is the value written by the fragment shader. The
  ///  destination color is the value currently existing in the texture.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuBlendFactor = (
    Invalid               = SDL_GPU_BLENDFACTOR_INVALID,

    /// <summary>
    ///  0
    /// </summary>
    Zero                  = SDL_GPU_BLENDFACTOR_ZERO,

    /// <summary>
    ///  1
    /// </summary>
    One                   = SDL_GPU_BLENDFACTOR_ONE,

    /// <summary>
    ///  Source color
    /// </summary>
    SrcColor              = SDL_GPU_BLENDFACTOR_SRC_COLOR,

    /// <summary>
    ///  1 - Source color
    /// </summary>
    OneMinusSrcColor      = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR,

    /// <summary>
    ///  Destination color
    /// </summary>
    DstColor              = SDL_GPU_BLENDFACTOR_DST_COLOR,

    /// <summary>
    ///  1 - Destination color
    /// </summary>
    OneMinusDstColor      = SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR,

    /// <summary>
    ///  Source alpha
    /// </summary>
    SrcAlpha              = SDL_GPU_BLENDFACTOR_SRC_ALPHA,

    /// <summary>
    ///  1 - Source alpha
    /// </summary>
    OneMinusSrcAlpha      = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,

    /// <summary>
    ///  Destination alpha
    /// </summary>
    DstAlpha              = SDL_GPU_BLENDFACTOR_DST_ALPHA,

    /// <summary>
    ///  1 - Destination alpha
    /// </summary>
    OneMinusDstAlpha      = SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA,

    /// <summary>
    ///  Blend constant
    /// </summary>
    ConstantColor         = SDL_GPU_BLENDFACTOR_CONSTANT_COLOR,

    /// <summary>
    ///  1 - Blend constant
    /// </summary>
    OneMinusConstantColor = SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR,

    /// <summary>
    ///  Min(Source alpha, 1 - Destination alpha)
    /// </summary>
    SrcAlphaSaturate      = SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE);

type
  /// <summary>
  ///  Specifies which color components are written in a graphics pipeline.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuColorComponentFlag = (
    R = 0,  // the red component
    G = 1,  // the green component
    B = 2,  // the blue component
    A = 3); // the alpha component
  TSdlGpuColorComponentFlags = set of TSdlGpuColorComponentFlag;

type
  /// <summary>
  ///  Specifies a filter operation used by a sampler.
  /// </summary>
  /// <seealso cref="TSdlGpuSampler"/>
  TSdlGpuFilter = (
    /// <summary>
    ///  Point filtering.
    /// </summary>
    Nearest = SDL_GPU_FILTER_NEAREST,

    /// <summary>
    ///  Linear filtering.
    /// </summary>
    Linear  = SDL_GPU_FILTER_LINEAR);

type
  /// <summary>
  ///  Specifies a mipmap mode used by a sampler.
  /// </summary>
  /// <seealso cref="TSdlGpuSampler"/>
  TSdlGpuSamplerMipmapMode = (
    /// <summary>
    ///  Point filtering.
    /// </summary>
    Nearest = SDL_GPU_SAMPLERMIPMAPMODE_NEAREST,

    /// <summary>
    ///  Linear filtering.
    /// </summary>
    Linear  = SDL_GPU_SAMPLERMIPMAPMODE_LINEAR);

type
  /// <summary>
  ///  Specifies behavior of texture sampling when the coordinates exceed the 0-1
  ///  range.
  /// </summary>
  /// <seealso cref="TSdlGpuSampler"/>
  TSdlGpuSamplerAddressMode = (
    /// <summary>
    ///  Specifies that the coordinates will wrap around.
    /// </summary>
    &Repeat        = SDL_GPU_SAMPLERADDRESSMODE_REPEAT,

    /// <summary>
    ///  Specifies that the coordinates will wrap around mirrored.
    /// </summary>
    MirroredRepeat = SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT,

    /// <summary>
    ///  Specifies that the coordinates will clamp to the 0-1 range.
    /// </summary>
    ClampToEdge    = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE);

type
  /// <summary>
  ///  Specifies the timing that will be used to present swapchain textures to the
  ///  OS.
  ///
  ///  VSync mode will always be supported. Immediate and Mailbox modes may not be
  ///  supported on certain systems.
  ///
  ///  It is recommended to query TSdlGpuDevice.WindowSupportsPresentMode after
  ///  claiming the window if you wish to change the present mode to Immediate or
  ///  Mailbox.
  ///
  ///  - VSync: Waits for vblank before presenting. No tearing is possible. If
  ///    there is a pending image to present, the new image is enqueued for
  ///    presentation. Disallows tearing at the cost of visual latency.
  ///  - Immediate: Immediately presents. Lowest latency option, but tearing may
  ///    occur.
  ///  - Mailbox: Waits for vblank before presenting. No tearing is possible. If
  ///    there is a pending image to present, the pending image is replaced by the
  ///    new image. Similar to VSync, but with reduced visual latency.
  /// </summary>
  /// <seealso cref="TSdlGpuDevice.SetSwapchainParameters"/>
  /// <seealso cref="TSdlGpuDevice.WindowSupportsPresentMode"/>
  /// <seealso cref="TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture"/>
  TSdlGpuPresentMode = (
    VSync     = SDL_GPU_PRESENTMODE_VSYNC,
    Immediate = SDL_GPU_PRESENTMODE_IMMEDIATE,
    Mailbox   = SDL_GPU_PRESENTMODE_MAILBOX);

type
  /// <summary>
  ///  Specifies the texture format and colorspace of the swapchain textures.
  ///
  ///  Sdr will always be supported. Other compositions may not be supported on
  ///  certain systems.
  ///
  ///  It is recommended to query TSdlGpuDevice.WindowSupportsSwapchainComposition
  ///  after claiming the window if you wish to change the swapchain composition
  ///  from Sdr.
  ///
  ///  - Sdr: B8G8R8A8 or R8G8B8A8 swapchain. Pixel values are in sRGB encoding.
  ///  - SdrLinear: B8G8R8A8Srgb or R8G8B8A8Srgb swapchain. Pixel values are
  ///    stored in memory in sRGB encoding but accessed in shaders in "linear
  ///    sRGB" encoding which is sRGB but with a linear transfer function.
  ///  - HdrExtendedLinear: R16G16B16A16Float swapchain. Pixel values are in
  ///    extended linear sRGB encoding and permits values outside of the [0, 1]
  ///    range.
  ///  - Hdr10ST2084: A2R10G10B10 or A2B10G10R10 swapchain. Pixel values are in
  ///    BT.2020 ST2084 (PQ) encoding.
  /// </summary>
  /// <seealso cref="TSdlGpuDevice.SetSwapchainParameters"/>
  /// <seealso cref="TSdlGpuDevice.WindowSupportsSwapchainComposition"/>
  /// <seealso cref="TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture"/>
  TSdlGpuSwapchainComposition = (
    Sdr               = SDL_GPU_SWAPCHAINCOMPOSITION_SDR,
    SdrLinear         = SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR,
    HdrExtendedLinear = SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR,
    Hdr10ST2084       = SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084);

type
  /// <summary>
  ///  A record specifying a viewport.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.SetViewport"/>
  TSdlGpuViewport = record
  public
    /// <summary>
    ///  The left offset of the viewport.
    /// </summary>
    X: Single;

    /// <summary>
    ///  The top offset of the viewport.
    /// </summary>
    Y: Single;

    /// <summary>
    ///  The width of the viewport.
    /// </summary>
    W: Single;

    /// <summary>
    ///  The height of the viewport.
    /// </summary>
    H: Single;

    /// <summary>
    ///  The minimum depth of the viewport.
    /// </summary>
    MinDepth: Single;

    /// <summary>
    ///  The maximum depth of the viewport.
    /// </summary>
    MaxDepth: Single;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of an indirect draw command.
  ///
  ///  Note that the `FirstVertex` and `FirstInstance` fields are NOT
  ///  compatible with built-in vertex/instance ID variables in shaders (for
  ///  example, SV_VertexID); GPU APIs and shader languages do not define these
  ///  built-in variables consistently, so if your shader depends on them, the
  ///  only way to keep behavior consistent and portable is to always pass 0 for
  ///  the correlating parameter in the draw calls.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.DrawPrimitives"/>
  TSdlGpuIndirectDrawCommand = record
  public
    /// <summary>
    ///  The number of vertices to draw.
    /// </summary>
    NumVertices: Integer;

    /// <summary>
    ///  The number of instances to draw.
    /// </summary>
    NumInstances: Integer;

    /// <summary>
    ///  The index of the first vertex to draw.
    /// </summary>
    FirstVertex: Integer;

    /// <summary>
    ///  The ID of the first instance to draw.
    /// </summary>
    FirstInstance: Integer;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of an indexed indirect draw command.
  ///
  ///  Note that the `FirstVertex` and `FirstInstance` fields are NOT
  ///  compatible with built-in vertex/instance ID variables in shaders (for
  ///  example, SV_VertexID); GPU APIs and shader languages do not define these
  ///  built-in variables consistently, so if your shader depends on them, the
  ///  only way to keep behavior consistent and portable is to always pass 0 for
  ///  the correlating parameter in the draw calls.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.DrawIndexedPrimitives"/>
  TSdlGpuIndexedIndirectDrawCommand = record
  public
    /// <summary>
    ///  The number of indices to draw per instance.
    /// </summary>
    NumIndices: Integer;

    /// <summary>
    ///  The number of instances to draw.
    /// </summary>
    NumInstances: Integer;

    /// <summary>
    ///  The base index within the index buffer.
    /// </summary>
    FirstIndex: Integer;

    /// <summary>
    ///  The value added to the vertex index before indexing into the vertex buffer.
    /// </summary>
    VertexOffset: Integer;

    /// <summary>
    ///  The ID of the first instance to draw.
    /// </summary>
    FirstInstance: Integer;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of an indexed dispatch command.
  /// </summary>
  /// <seealso cref="TSdlGpuComputePass.Dispatch"/>
  TSdlGpuIndirectDispatchCommand = record
  public
    /// <summary>
    ///  The number of local workgroups to dispatch in the X dimension.
    /// </summary>
    GroupCountX: Integer;

    /// <summary>
    ///  The number of local workgroups to dispatch in the Y dimension.
    /// </summary>
    GroupCountY: Integer;

    /// <summary>
    ///  The number of local workgroups to dispatch in the Z dimension.
    /// </summary>
    GroupCountZ: Integer;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a sampler.
  ///
  ///  Note that MipLodBias is a no-op for the Metal driver. For Metal, LOD bias
  ///  must be applied via shader instead.
  /// </summary>
  /// <seealso cref="TSdlGpuSampler"/>
  /// <seealso cref="TSdlGpuFilter"/>
  /// <seealso cref="TSdlGpuSamplerMipmapMode"/>
  /// <seealso cref="TSdlGpuSamplerAddressMode"/>
  /// <seealso cref="TSdlGpuCompareOp"/>
  TSdlGpuSamplerCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUSamplerCreateInfo;
    function GetMinFilter: TSdlGpuFilter; inline;
    procedure SetMinFilter(const AValue: TSdlGpuFilter); inline;
    function GetMagFilter: TSdlGpuFilter; inline;
    procedure SetMagFilter(const AValue: TSdlGpuFilter); inline;
    function GetMipmapMode: TSdlGpuSamplerMipmapMode; inline;
    procedure SetMipmapMode(const AValue: TSdlGpuSamplerMipmapMode); inline;
    function GetAddressModeU: TSdlGpuSamplerAddressMode; inline;
    procedure SetAddressModeU(const AValue: TSdlGpuSamplerAddressMode); inline;
    function GetAddressModeV: TSdlGpuSamplerAddressMode; inline;
    procedure SetAddressModeV(const AValue: TSdlGpuSamplerAddressMode); inline;
    function GetAddressModeW: TSdlGpuSamplerAddressMode; inline;
    procedure SetAddressModeW(const AValue: TSdlGpuSamplerAddressMode); inline;
    function GetCompareOp: TSdlGpuCompareOp; inline;
    procedure SetCompareOp(const AValue: TSdlGpuCompareOp); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuSamplerCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  The minification filter to apply to lookups.
    /// </summary>
    property MinFilter: TSdlGpuFilter read GetMinFilter write SetMinFilter;

    /// <summary>
    ///  The magnification filter to apply to lookups.
    /// </summary>
    property MagFilter: TSdlGpuFilter read GetMagFilter write SetMagFilter;

    /// <summary>
    ///  The mipmap filter to apply to lookups.
    /// </summary>
    property MipmapMode: TSdlGpuSamplerMipmapMode read GetMipmapMode write SetMipmapMode;

    /// <summary>
    ///  The addressing mode for U coordinates outside [0, 1).
    /// </summary>
    property AddressModeU: TSdlGpuSamplerAddressMode read GetAddressModeU write SetAddressModeU;

    /// <summary>
    ///  The addressing mode for V coordinates outside [0, 1).
    /// </summary>
    property AddressModeV: TSdlGpuSamplerAddressMode read GetAddressModeV write SetAddressModeV;

    /// <summary>
    ///  The addressing mode for W coordinates outside [0, 1).
    /// </summary>
    property AddressModeW: TSdlGpuSamplerAddressMode read GetAddressModeW write SetAddressModeW;

    /// <summary>
    ///  The bias to be added to mipmap LOD calculation.
    ///  Note that this is a no-op for the Metal driver. For Metal, LOD bias
    ///  must be applied via shader instead.
    /// </summary>
    property MipLodBias: Single read FHandle.mip_lod_bias write FHandle.mip_lod_bias;

    /// <summary>
    ///  The anisotropy value clamp used by the sampler. If enable_anisotropy is false, this is ignored.
    /// </summary>
    property MaxAnisotropy: Single read FHandle.max_anisotropy write FHandle.max_anisotropy;

    /// <summary>
    ///  The comparison operator to apply to fetched data before filtering.
    /// </summary>
    property CompareOp: TSdlGpuCompareOp read GetCompareOp write SetCompareOp;

    /// <summary>
    ///  Clamps the minimum of the computed LOD value.
    /// </summary>
    property MinLod: Single read FHandle.min_lod write FHandle.min_lod;

    /// <summary>
    ///  Clamps the maximum of the computed LOD value.
    /// </summary>
    property MaxLod: Single read FHandle.max_lod write FHandle.max_lod;

    /// <summary>
    ///  True to enable anisotropic filtering.
    /// </summary>
    property AnisotropyEnabled: Boolean read FHandle.enable_anisotropy write FHandle.enable_anisotropy;

    /// <summary>
    ///  True to enable comparison against a reference value during lookups.
    /// </summary>
    property CompareEnabled: Boolean read FHandle.enable_compare write FHandle.enable_compare;

    /// <summary>
    ///  A properties ID for extensions. Should be 0 if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of vertex buffers used in a graphics
  ///  pipeline.
  ///
  ///  When you call TSdlGpuRenderPass.BindVertexBuffers, you specify the
  ///  binding slots of the vertex buffers. For example if you called
  ///  TSdlGpuRenderPass.BindVertexBuffers with a AFirstSlot of 2 and
  ///  ANumBindings of 3, the binding slots 2, 3, 4 would be used by the vertex
  ///  buffers you pass in.
  ///
  ///  Vertex attributes are linked to buffers via the BufferSlot field of
  ///  TSdlGpuVertexAttribute. For example, if an attribute has a buffer_slot of
  ///  0, then that attribute belongs to the vertex buffer bound at slot 0.
  /// </summary>
  /// <seealso cref="TSdlGpuVertexAttribute"/>
  /// <seealso cref="TSdlGpuVertexInputRate"/>
  TSdlGpuVertexBufferDescription = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUVertexBufferDescription;
    function GetInputRate: TSdlGpuVertexInputRate; inline;
    procedure SetInputRate(const AValue: TSdlGpuVertexInputRate); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The binding slot of the vertex buffer.
    /// </summary>
    property Slot: Integer read FHandle.slot write FHandle.slot;

    /// <summary>
    ///  The byte pitch between consecutive elements of the vertex buffer.
    /// </summary>
    property Pitch: Integer read FHandle.pitch write FHandle.pitch;

    /// <summary>
    ///  Whether attribute addressing is a function of the vertex index or instance index.
    /// </summary>
    property InputRate: TSdlGpuVertexInputRate read GetInputRate write SetInputRate;
  end;

type
  /// <summary>
  ///  A record specifying a vertex attribute.
  ///
  ///  All vertex attribute locations provided to an TSdlGpuVertexInputState must
  ///  be unique.
  /// </summary>
  /// <seealso cref="TSdlGpuVertexBufferDescription"/>
  /// <seealso cref="TSdlGpuVertexInputState"/>
  /// <seealso cref="TSdlGpuVertexElementFormat"/>
  TSdlGpuVertexAttribute = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUVertexAttribute;
    function GetFormat: TSdlGpuVertexElementFormat; inline;
    procedure SetFormat(const AValue: TSdlGpuVertexElementFormat); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The shader input location index.
    /// </summary>
    property Location: Integer read FHandle.location write FHandle.location;

    /// <summary>
    ///  The binding slot of the associated vertex buffer.
    /// </summary>
    property BufferSlot: Integer read FHandle.buffer_slot write FHandle.buffer_slot;

    /// <summary>
    ///  The size and type of the attribute data.
    /// </summary>
    property Format: TSdlGpuVertexElementFormat read GetFormat write SetFormat;

    /// <summary>
    ///  The byte offset of this attribute relative to the start of the vertex element.
    /// </summary>
    property Offset: Integer read FHandle.offset write FHandle.offset;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a graphics pipeline vertex input
  ///  state.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipelineCreateInfo"/>
  /// <seealso cref="TSdlGpuVertexBufferDescription"/>
  /// <seealso cref="TSdlGpuVertexAttribute"/>
  TSdlGpuVertexInputState = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUVertexInputState;
    FVertexBufferDescriptions: TArray<TSdlGpuVertexBufferDescription>; // Keep alive
    FVertexAttributes: TArray<TSdlGpuVertexAttribute>;                 // Keep alive
    procedure SetVertexBufferDescriptions(const AValue: TArray<TSdlGpuVertexBufferDescription>);
    procedure SetVertexAttributes(const AValue: TArray<TSdlGpuVertexAttribute>);
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  An array of vertex buffer descriptions.
    /// </summary>
    property VertexBufferDescriptions: TArray<TSdlGpuVertexBufferDescription> read FVertexBufferDescriptions write SetVertexBufferDescriptions;

    /// <summary>
    ///  An array of vertex attribute descriptions.
    /// </summary>
    property VertexAttributes: TArray<TSdlGpuVertexAttribute> read FVertexAttributes write SetVertexAttributes;
  end;

type
  /// <summary>
  ///  A record specifying the stencil operation state of a graphics pipeline.
  /// </summary>
  /// <seealso cref="TSdlGpuDepthStencilState"/>
  TSdlGpuStencilOpState = record
  public
    /// <summary>
    ///  The action performed on samples that fail the stencil test.
    /// </summary>
    FailOp: TSdlGpuStencilOp;

    /// <summary>
    ///  The action performed on samples that pass the depth and stencil tests.
    /// </summary>
    PassOp: TSdlGpuStencilOp;

    /// <summary>
    ///  The action performed on samples that pass the stencil test and fail the depth test.
    /// </summary>
    DepthFailOp: TSdlGpuStencilOp;

    /// <summary>
    ///  The comparison operator used in the stencil test.
    /// </summary>
    CompareOp: TSdlGpuCompareOp;
  end;
  PSdlGpuStencilOpState = ^TSdlGpuStencilOpState;

type
  /// <summary>
  ///  A record specifying the blend state of a color target.
  /// </summary>
  /// <seealso cref="TSdlGpuColorTargetDescription"/>
  TSdlGpuColorTargetBlendState = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUColorTargetBlendState;
    function GetSrcColorBlendFactor: TSdlGpuBlendFactor; inline;
    procedure SetSrcColorBlendFactor(const AValue: TSdlGpuBlendFactor); inline;
    function GetDstColorBlendFactor: TSdlGpuBlendFactor; inline;
    procedure SetDstColorBlendFactor(const AValue: TSdlGpuBlendFactor); inline;
    function GetColorBlendOp: TSdlGpuBlendOp; inline;
    procedure SetColorBlendOp(const AValue: TSdlGpuBlendOp); inline;
    function GetSrcAlphaBlendFactor: TSdlGpuBlendFactor; inline;
    procedure SetSrcAlphaBlendFactor(const AValue: TSdlGpuBlendFactor); inline;
    function GetDstAlphaBlendFctor: TSdlGpuBlendFactor; inline;
    procedure SetDstAlphaBlendFctor(const AValue: TSdlGpuBlendFactor); inline;
    function GetAlphaBlendOp: TSdlGpuBlendOp; inline;
    procedure SetAlphaBlendOp(const AValue: TSdlGpuBlendOp); inline;
    function GetColorWriteMask: TSdlGpuColorComponentFlags; inline;
    procedure SetColorWriteMask(const AValue: TSdlGpuColorComponentFlags); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The value to be multiplied by the source RGB value.
    /// </summary>
    property SrcColorBlendFactor: TSdlGpuBlendFactor read GetSrcColorBlendFactor write SetSrcColorBlendFactor;

    /// <summary>
    ///  The value to be multiplied by the destination RGB value.
    /// </summary>
    property DstColorBlendFactor: TSdlGpuBlendFactor read GetDstColorBlendFactor write SetDstColorBlendFactor;

    /// <summary>
    ///  The blend operation for the RGB components.
    /// </summary>
    property ColorBlendOp: TSdlGpuBlendOp read GetColorBlendOp write SetColorBlendOp;

    /// <summary>
    ///  The value to be multiplied by the source alpha.
    /// </summary>
    property SrcAlphaBlendFactor: TSdlGpuBlendFactor read GetSrcAlphaBlendFactor write SetSrcAlphaBlendFactor;

    /// <summary>
    ///  The value to be multiplied by the destination alpha.
    /// </summary>
    property DstAlphaBlendFctor: TSdlGpuBlendFactor read GetDstAlphaBlendFctor write SetDstAlphaBlendFctor;

    /// <summary>
    ///  The blend operation for the alpha component.
    /// </summary>
    property AlphaBlendOp: TSdlGpuBlendOp read GetAlphaBlendOp write SetAlphaBlendOp;

    /// <summary>
    ///  A bitmask specifying which of the RGBA components are enabled for writing. Writes to all channels if enable_color_write_mask is false.
    /// </summary>
    property ColorWriteMask: TSdlGpuColorComponentFlags read GetColorWriteMask write SetColorWriteMask;

    /// <summary>
    ///  Whether blending is enabled for the color target.
    /// </summary>
    property BlendEnabled: Boolean read FHandle.enable_blend write FHandle.enable_blend;

    /// <summary>
    ///  Whether the color write mask is enabled.
    /// </summary>
    property ColorWriteMaskEnabled: Boolean read FHandle.enable_color_write_mask write FHandle.enable_color_write_mask;
  end;
  PSdlGpuColorTargetBlendState = ^TSdlGpuColorTargetBlendState;

type
  /// <summary>
  ///  A record specifying code and metadata for creating a shader object.
  /// </summary>
  /// <seealso cref="TSdlGpuShader"/>
  TSdlGpuShaderCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUShaderCreateInfo;
    FCode: TBytes;           // Keep alive
    FEntryPoint: UTF8String; // Keep alive
    procedure SetCode(const AValue: TBytes);
    function GetEntryPoint: String;
    procedure SetEntryPoint(const AValue: String);
    function GetFormat: TSdlGpuShaderFormat; inline;
    procedure SetFormat(const AValue: TSdlGpuShaderFormat); inline;
    function GetStage: TSdlGpuShaderStage; inline;
    procedure SetStage(const AValue: TSdlGpuShaderStage); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuShaderCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  The shader code.
    /// </summary>
    property Code: TBytes read FCode write SetCode;

    /// <summary>
    ///  The entry point function name for the shader.
    /// </summary>
    property EntryPoint: String read GetEntryPoint write SetEntryPoint;

    /// <summary>
    ///  The format of the shader code.
    /// </summary>
    property Format: TSdlGpuShaderFormat read GetFormat write SetFormat;

    /// <summary>
    ///  The stage the shader program corresponds to.
    /// </summary>
    property Stage: TSdlGpuShaderStage read GetStage write SetStage;

    /// <summary>
    ///  The number of samplers defined in the shader.
    /// </summary>
    property NumSamplers: Integer read FHandle.num_samplers write FHandle.num_samplers;

    /// <summary>
    ///  The number of storage textures defined in the shader.
    /// </summary>
    property NumStorageTextures: Integer read FHandle.num_storage_textures write FHandle.num_storage_textures;

    /// <summary>
    ///  The number of storage buffers defined in the shader.
    /// </summary>
    property NumStorageBuffers: Integer read FHandle.num_storage_buffers write FHandle.num_storage_buffers;

    /// <summary>
    ///  The number of uniform buffers defined in the shader.
    /// </summary>
    property NumUniformBuffers: Integer read FHandle.num_uniform_buffers write FHandle.num_uniform_buffers;

    /// <summary>
    ///  A properties ID for extensions. Should be 0 if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a texture.
  ///
  ///  Note that certain usage combinations are invalid, for example Sampler and
  ///  GraphicsStorage.
  /// </summary>
  /// <seealso cref="TSdlGpuTexture"/>
  /// <seealso cref="TSdlGpuTextureKind"/>
  /// <seealso cref="TSdlGpuTextureFormat"/>
  /// <seealso cref="TSdlGpuTextureUsageFlags"/>
  /// <seealso cref="TSdlGpuSampleCount"/>
  TSdlGpuTextureCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTextureCreateInfo;
    function GetKind: TSdlGpuTextureKind; inline;
    procedure SetKind(const AValue: TSdlGpuTextureKind); inline;
    function GetFormat: TSdlGpuTextureFormat; inline;
    procedure SetFormat(const AValue: TSdlGpuTextureFormat); inline;
    function GetUsage: TSdlGpuTextureUsageFlags; inline;
    procedure SetUsage(const AValue: TSdlGpuTextureUsageFlags); inline;
    function GetSampleCount: TSdlGpuSampleCount; inline;
    procedure SetSampleCount(const AValue: TSdlGpuSampleCount); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuTextureCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  The base dimensionality of the texture.
    /// </summary>
    property Kind: TSdlGpuTextureKind read GetKind write SetKind;

    /// <summary>
    ///  The pixel format of the texture.
    /// </summary>
    property Format: TSdlGpuTextureFormat read GetFormat write SetFormat;

    /// <summary>
    ///  How the texture is intended to be used by the client.
    /// </summary>
    property Usage: TSdlGpuTextureUsageFlags read GetUsage write SetUsage;

    /// <summary>
    ///  The width of the texture.
    /// </summary>
    property Width: Integer read FHandle.width write FHandle.width;

    /// <summary>
    ///  The height of the texture.
    /// </summary>
    property Height: Integer read FHandle.height write FHandle.height;

    /// <summary>
    ///  The layer count or depth of the texture. This value is treated as a
    ///  layer count on 2D array textures, and as a depth value on 3D textures.
    /// </summary>
    property LayerCountOrDepth: Integer read FHandle.layer_count_or_depth write FHandle.layer_count_or_depth;

    /// <summary>
    ///  The number of mip levels in the texture.
    /// </summary>
    property NumLevels: Integer read FHandle.num_levels write FHandle.num_levels;

    /// <summary>
    ///  The number of samples per texel. Only applies if the texture is used as a render target.
    /// </summary>
    property SampleCount: TSdlGpuSampleCount read GetSampleCount write SetSampleCount;

    /// <summary>
    ///  A properties ID for extensions. Should be 0 if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a buffer.
  ///
  ///  Note that certain combinations are invalid, for example Vertex and Index.
  /// </summary>
  /// <seealso cref="TSdlGpuBuffer"/>
  /// <seealso cref="TSdlGpuBufferUsageFlags"/>
  TSdlGpuBufferCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBufferCreateInfo;
    function GetUsage: TSdlGpuBufferUsageFlags; inline;
    procedure SetUsage(const AValue: TSdlGpuBufferUsageFlags); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuBufferCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  How the buffer is intended to be used by the client.
    /// </summary>
    property Usage: TSdlGpuBufferUsageFlags read GetUsage write SetUsage;

    /// <summary>
    ///  The size in bytes of the buffer.
    /// </summary>
    property Size: Integer read FHandle.size write FHandle.size;

    /// <summary>
    ///  A properties ID for extensions. Should be 0 if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a transfer buffer.
  /// </summary>
  /// <seealso cref="TSdlGpuTransferBuffer"/>
  TSdlGpuTransferBufferCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTransferBufferCreateInfo;
    function GetUsage: TSdlGpuTransferBufferUsage; inline;
    procedure SetUsage(const AValue: TSdlGpuTransferBufferUsage); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuTransferBufferCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  How the transfer buffer is intended to be used by the client.
    /// </summary>
    property Usage: TSdlGpuTransferBufferUsage read GetUsage write SetUsage;

    /// <summary>
    ///  The size in bytes of the transfer buffer.
    /// </summary>
    property Size: Integer read FHandle.size write FHandle.size;

    /// <summary>
    ///  A properties ID for extensions. Should be 0 if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of the graphics pipeline rasterizer
  ///  state.
  ///
  ///  Note that TSdlGpuFillMode.Line is not supported on many Android devices.
  ///  For those devices, the fill mode will automatically fall back to Fill.
  ///  Also note that the D3D12 driver will enable depth clamping even if
  ///  DepthClipEnabled is True. If you need this clamp+clip behavior, consider
  ///  enabling depth clip and then manually clamping depth in your fragment
  ///  shaders on Metal and Vulkan.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipelineCreateInfo"/>
  TSdlGpuRasterizerState = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPURasterizerState;
    function GetFillMode: TSdlGpuFillMode; inline;
    procedure SetFillMode(const AValue: TSdlGpuFillMode); inline;
    function GetCullMode: TSdlGpuCullMode; inline;
    procedure SetCullMode(const AValue: TSdlGpuCullMode); inline;
    function GetFrontFace: TSdlGpuFrontFace; inline;
    procedure SetFrontFace(const AValue: TSdlGpuFrontFace); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Whether polygons will be filled in or drawn as lines.
    /// </summary>
    property FillMode: TSdlGpuFillMode read GetFillMode write SetFillMode;

    /// <summary>
    ///  The facing direction in which triangles will be culled.
    /// </summary>
    property CullMode: TSdlGpuCullMode read GetCullMode write SetCullMode;

    /// <summary>
    ///  The vertex winding that will cause a triangle to be determined as front-facing.
    /// </summary>
    property FrontFace: TSdlGpuFrontFace read GetFrontFace write SetFrontFace;

    /// <summary>
    ///  A scalar factor controlling the depth value added to each fragment.
    /// </summary>
    property DepthBiasConstantFactor: Single read FHandle.depth_bias_constant_factor write FHandle.depth_bias_constant_factor;

    /// <summary>
    ///  The maximum depth bias of a fragment.
    /// </summary>
    property DepthBiasClamp: Single read FHandle.depth_bias_clamp write FHandle.depth_bias_clamp;

    /// <summary>
    ///  A scalar factor applied to a fragment's slope in depth calculations.
    /// </summary>
    property DepthBiasSlopeFactor: Single read FHandle.depth_bias_slope_factor write FHandle.depth_bias_slope_factor;

    /// <summary>
    ///  True to bias fragment depth values.
    /// </summary>
    property DepthBiasEnabled: Boolean read FHandle.enable_depth_bias write FHandle.enable_depth_bias;

    /// <summary>
    ///  True to enable depth clip, False to enable depth clamp.
    /// </summary>
    property DepthClipEnabled: Boolean read FHandle.enable_depth_clip write FHandle.enable_depth_clip;
  end;
  PSdlGpuRasterizerState = ^TSdlGpuRasterizerState;

type
  /// <summary>
  ///  A record specifying the parameters of the graphics pipeline multisample
  ///  state.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipelineCreateInfo"/>
  /// <remarks>
  ///  This struct is available since SDL 3.2.0.
  /// </remarks>
  TSdlGpuMultisampleState = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUMultisampleState;
    function GetSampleCount: TSdlGpuSampleCount; inline;
    procedure SetSampleCount(const AValue: TSdlGpuSampleCount); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The number of samples to be used in rasterization.
    /// </summary>
    property SampleCount: TSdlGpuSampleCount read GetSampleCount write SetSampleCount;
  end;
  PSdlGpuMultisampleState = ^TSdlGpuMultisampleState;

type
  /// <summary>
  ///  A record specifying the parameters of the graphics pipeline depth
  ///  stencil state.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipelineCreateInfo"/>
  TSdlGpuDepthStencilState = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUDepthStencilState;
    function GetCompareOp: TSdlGpuCompareOp; inline;
    procedure SetCompareOp(const AValue: TSdlGpuCompareOp); inline;
    function GetBackStencilState: PSdlGpuStencilOpState; inline;
    function GetFrontStencilState: PSdlGpuStencilOpState; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The comparison operator used for depth testing.
    /// </summary>
    property CompareOp: TSdlGpuCompareOp read GetCompareOp write SetCompareOp;

    /// <summary>
    ///  The stencil op state for back-facing triangles.
    /// </summary>
    property BackStencilState: PSdlGpuStencilOpState read GetBackStencilState;

    /// <summary>
    ///  The stencil op state for front-facing triangles.
    /// </summary>
    property FrontStencilState: PSdlGpuStencilOpState read GetFrontStencilState;

    /// <summary>
    ///  Selects the bits of the stencil values participating in the stencil test.
    /// </summary>
    property CompareMask: Byte read FHandle.compare_mask write FHandle.compare_mask;

    /// <summary>
    ///  Selects the bits of the stencil values updated by the stencil test.
    /// </summary>
    property WriteMask: Byte read FHandle.write_mask write FHandle.write_mask;

    /// <summary>
    ///  True enables the depth test.
    /// </summary>
    property DepthTestEnabled: Boolean read FHandle.enable_depth_test write FHandle.enable_depth_test;

    /// <summary>
    ///  True enables depth writes. Depth writes are always disabled when
    ///  this is false.
    /// </summary>
    property DepthWriteEnabled: Boolean read FHandle.enable_depth_write write FHandle.enable_depth_write;

    /// <summary>
    ///  True enables the stencil test.
    /// </summary>
    property StencilTestEnabled: Boolean read FHandle.enable_stencil_test write FHandle.enable_stencil_test;
  end;
  PSdlGpuDepthStencilState = ^TSdlGpuDepthStencilState;

type
  /// <summary>
  ///  A record specifying the parameters of color targets used in a graphics
  ///  pipeline.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipelineTargetInfo"/>
  TSdlGpuColorTargetDescription = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUColorTargetDescription;
    function GetFormat: TSdlGpuTextureFormat; inline;
    procedure SetFormat(const AValue: TSdlGpuTextureFormat); inline;
    function GetBlendState: PSdlGpuColorTargetBlendState; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The pixel format of the texture to be used as a color target.
    /// </summary>
    property Format: TSdlGpuTextureFormat read GetFormat write SetFormat;

    /// <summary>
    ///  The blend state to be used for the color target.
    /// </summary>
    property BlendState: PSdlGpuColorTargetBlendState read GetBlendState;
  end;

type
  /// <summary>
  ///  A record specifying the descriptions of render targets used in a
  ///  graphics pipeline.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipelineCreateInfo"/>
  /// <seealso cref="TSdlGpuColorTargetDescription"/>
  /// <seealso cref="TSdlGpuTextureFormat"/>
  TSdlGpuGraphicsPipelineTargetInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUGraphicsPipelineTargetInfo;
    FColorTargetDescriptions: TArray<TSdlGpuColorTargetDescription>; // Keep alive
    procedure SetColorTargetDescriptions(const AValue: TArray<TSdlGpuColorTargetDescription>);
    function GetDepthStencilFormat: TSdlGpuTextureFormat; inline;
    procedure SetDepthStencilFormat(const AValue: TSdlGpuTextureFormat); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  An array of color target descriptions.
    /// </summary>
    property ColorTargetDescriptions: TArray<TSdlGpuColorTargetDescription> read FColorTargetDescriptions write SetColorTargetDescriptions;

    /// <summary>
    ///  The pixel format of the depth-stencil target.
    //   Ignored if HasDepthStencilTarget is False.
    /// </summary>
    property DepthStencilFormat: TSdlGpuTextureFormat read GetDepthStencilFormat write SetDepthStencilFormat;

    /// <summary>
    ///  True specifies that the pipeline uses a depth-stencil target.
    /// </summary>
    property HasDepthStencilTarget: Boolean read FHandle.has_depth_stencil_target write FHandle.has_depth_stencil_target;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a compute pipeline state.
  /// </summary>
  /// <seealso cref="TSdlGpuComputePipeline"/>
  /// <seealso cref="TSdlGpuShaderFormat"/>
  /// <remarks>
  ///  This struct is available since SDL 3.2.0.
  /// </remarks>
  TSdlGpuComputePipelineCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUComputePipelineCreateInfo;
    FCode: TBytes;           // Keep alive
    FEntryPoint: UTF8String; // Keep alive
    procedure SetCode(const AValue: TBytes);
    function GetEntryPoint: String;
    procedure SetEntryPoint(const AValue: String);
    function GetFormat: TSdlGpuShaderFormat; inline;
    procedure SetFormat(const AValue: TSdlGpuShaderFormat); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuComputePipelineCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  The compute shader code.
    /// </summary>
    property Code: TBytes read FCode write SetCode;

    /// <summary>
    ///  The entry point function name for the shader.
    /// </summary>
    property EntryPoint: String read GetEntryPoint write SetEntryPoint;

    /// <summary>
    ///  The format of the compute shader code.
    /// </summary>
    property Format: TSdlGpuShaderFormat read GetFormat write SetFormat;

    /// <summary>
    ///  The number of samplers defined in the shader.
    /// </summary>
    property NumSamplers: Integer read FHandle.num_samplers write FHandle.num_samplers;

    /// <summary>
    ///  The number of readonly storage textures defined in the shader.
    /// </summary>
    property NumReadonlyStorageTextures: Integer read FHandle.num_readonly_storage_textures write FHandle.num_readonly_storage_textures;

    /// <summary>
    ///  The number of readonly storage buffers defined in the shader.
    /// </summary>
    property NumReadonlyStorageBuffers: Integer read FHandle.num_readonly_storage_buffers write FHandle.num_readonly_storage_buffers;

    /// <summary>
    ///  The number of read-write storage textures defined in the shader.
    /// </summary>
    property NumReadWriteStorageTextures: Integer read FHandle.num_readwrite_storage_textures write FHandle.num_readwrite_storage_textures;

    /// <summary>
    ///  The number of read-write storage buffers defined in the shader.
    /// </summary>
    property NumReadWriteStorageBuffers: Integer read FHandle.num_readwrite_storage_buffers write FHandle.num_readwrite_storage_buffers;

    /// <summary>
    ///  The number of uniform buffers defined in the shader.
    /// </summary>
    property NumUniformBuffers: Integer read FHandle.num_uniform_buffers write FHandle.num_uniform_buffers;

    /// <summary>
    ///  The number of threads in the X dimension. This should match the value
    ///  in the shader.
    /// </summary>
    property ThreadCountX: Integer read FHandle.threadcount_x write FHandle.threadcount_x;

    /// <summary>
    ///  The number of threads in the Y dimension. This should match the value
    ///  in the shader.
    /// </summary>
    property ThreadCountY: Integer read FHandle.threadcount_y write FHandle.threadcount_y;

    /// <summary>
    ///  The number of threads in the Z dimension. This should match the value
    ///  in the shader.
    /// </summary>
    property ThreadCountZ: Integer read FHandle.threadcount_z write FHandle.threadcount_z;

    /// <summary>
    ///  A properties ID for extensions. Should be nil if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;

type
  /// <summary>
  ///  A compute pipeline. Used during compute passes.
  /// </summary>
  /// <seealso cref="TSdlGpuComputePass.BindPipeline"/>
  TSdlGpuComputePipeline = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUComputePipeline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuComputePipeline; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuComputePipeline.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuComputePipeline): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuComputePipeline; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuComputePipeline.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuComputePipeline): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuComputePipeline; inline; static;
  end;

type
  /// <summary>
  ///  A buffer used for vertices, indices, indirect draw commands, and general
  ///  compute data.
  /// </summary>
  /// <seealso cref="TSdlGpuDevice.CreateBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.UploadToBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.CopyBufferToBuffer"/>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexBuffers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindIndexBuffer"/>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexStorageBuffers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindFragmentStorageBuffers"/>
  /// <seealso cref="TSdlGpuRenderPass.DrawPrimitives"/>
  /// <seealso cref="TSdlGpuComputePass.BindStorageBuffers"/>
  /// <seealso cref="TSdlGpuComputePass.Dispatch"/>
  TSdlGpuBuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBuffer;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuBuffer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuBuffer.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuBuffer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuBuffer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuBuffer.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuBuffer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuBuffer; inline; static;
  end;

type
  /// <summary>
  ///  A record specifying a location in a buffer.
  ///
  ///  Used when copying data between buffers.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.CopyBufferToBuffer"/>
  TSdlGpuBufferLocation = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBufferLocation;
    function GetBuffer: TSdlGpuBuffer; inline;
    procedure SetBuffer(const AValue: TSdlGpuBuffer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The buffer.
    /// </summary>
    property Buffer: TSdlGpuBuffer read GetBuffer write SetBuffer;

    /// <summary>
    ///  The starting byte within the buffer.
    /// </summary>
    property Offset: Integer read FHandle.offset write FHandle.offset;
  end;

type
  /// <summary>
  ///  A record specifying a region of a buffer.
  ///
  ///  Used when transferring data to or from buffers.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.UploadToBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromBuffer"/>
  TSdlGpuBufferRegion = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBufferRegion;
    function GetBuffer: TSdlGpuBuffer; inline;
    procedure SetBuffer(const AValue: TSdlGpuBuffer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The buffer.
    /// </summary>
    property Buffer: TSdlGpuBuffer read GetBuffer write SetBuffer;

    /// <summary>
    ///  The starting byte within the buffer.
    /// </summary>
    property Offset: Integer read FHandle.offset write FHandle.offset;

    /// <summary>
    ///  The size in bytes of the region.
    /// </summary>
    property Size: Integer read FHandle.size write FHandle.size;
  end;

type
  /// <summary>
  ///  A record specifying parameters in a buffer binding call.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexBuffers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindIndexBuffer"/>
  TSdlGpuBufferBinding = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBufferBinding;
    function GetBuffer: TSdlGpuBuffer; inline;
    procedure SetBuffer(const AValue: TSdlGpuBuffer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The buffer to bind. Must have been created with
    ///  TSdlGpuBufferUsage.Vertex for TSdlGpuRenderPass.BindVertexBuffers, or
    ///  TSdlGpuBufferUsage.Index  for TSdlGpuRenderPass.BindIndexBuffer.
    /// </summary>
    property Buffer: TSdlGpuBuffer read GetBuffer write SetBuffer;

    /// <summary>
    ///  The starting byte of the data to bind in the buffer.
    /// </summary>
    property Offset: Integer read FHandle.offset write FHandle.offset;
  end;

type
  /// <summary>
  ///  A record specifying parameters related to binding buffers in a compute
  ///  pass.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginComputePass"/>
  TSdlGpuStorageBufferReadWriteBinding = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUStorageBufferReadWriteBinding;
    function GetBuffer: TSdlGpuBuffer; inline;
    procedure SetBuffer(const AValue: TSdlGpuBuffer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The buffer to bind. Must have been created with
    ///  TSdlGpuBufferUsage.ComputeStorageWrite.
    /// </summary>
    property Buffer: TSdlGpuBuffer read GetBuffer write SetBuffer;

    /// <summary>True cycles the buffer if it is already bound.</summary>
    property Cycle: Boolean read FHandle.cycle write FHandle.cycle;
  end;

type
  /// <summary>
  ///  A transfer buffer used for transferring data to and from the device.
  /// </summary>
  /// <seealso cref="TSdlGpuDevice.MapTransferBuffer"/>
  /// <seealso cref="TSdlGpuDevice.UnmapTransferBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.UploadToBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromBuffer"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
  TSdlGpuTransferBuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTransferBuffer;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuTransferBuffer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuTransferBuffer.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuTransferBuffer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuTransferBuffer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuTransferBuffer.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuTransferBuffer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuTransferBuffer; inline; static;
  end;

type
  /// <summary>
  ///  A record specifying parameters related to transferring data to or from a
  ///  texture.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
  TSdlGpuTextureTransferInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTextureTransferInfo;
    function GetTransferBuffer: TSdlGpuTransferBuffer; inline;
    procedure SetTransferBuffer(const AValue: TSdlGpuTransferBuffer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The transfer buffer used in the transfer operation.
    /// </summary>
    property TransferBuffer: TSdlGpuTransferBuffer read GetTransferBuffer write SetTransferBuffer;

    /// <summary>
    ///  The starting byte of the image data in the transfer buffer.
    /// </summary>
    property Offset: Integer read FHandle.offset write FHandle.offset;

    /// <summary>
    ///  The number of pixels from one row to the next.
    /// </summary>
    property PixelsPerRow: Integer read FHandle.pixels_per_row write FHandle.pixels_per_row;

    /// <summary>
    ///  The number of rows from one layer/depth-slice to the next.
    /// </summary>
    property RowsPerLayer: Integer read FHandle.rows_per_layer write FHandle.rows_per_layer;
  end;

type
  /// <summary>
  ///  A record specifying a location in a transfer buffer.
  ///
  ///  Used when transferring buffer data to or from a transfer buffer.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
  TSdlGpuTransferBufferLocation = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTransferBufferLocation;
    function GetTransferBuffer: TSdlGpuTransferBuffer; inline;
    procedure SetTransferBuffer(const AValue: TSdlGpuTransferBuffer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The transfer buffer used in the transfer operation.
    /// </summary>
    property TransferBuffer: TSdlGpuTransferBuffer read GetTransferBuffer write SetTransferBuffer;

    /// <summary>
    ///  The starting byte of the buffer data in the transfer buffer.
    /// </summary>
    property Offset: Integer read FHandle.offset write FHandle.offset;
  end;

type
  /// <summary>
  ///  A texture.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
  /// <seealso cref="TSdlGpuCopyPass.CopyTextureToTexture"/>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexSamplers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexStorageTextures"/>
  /// <seealso cref="TSdlGpuRenderPass.BindFragmentSamplers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindFragmentStorageTextures"/>
  /// <seealso cref="TSdlGpuComputePass.BindStorageTextures"/>
  /// <seealso cref="TSdlGpuCommandBuffer.GenerateMipmaps"/>
  /// <seealso cref="TSdlGpuCommandBuffer.Blit"/>
  TSdlGpuTexture = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTexture;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuTexture; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuTexture.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuTexture): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuTexture; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuTexture.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuTexture): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuTexture; inline; static;
  end;

type
  /// <summary>
  ///  A record specifying a location in a texture.
  ///
  ///  Used when copying data from one texture to another.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.CopyTextureToTexture"/>
  TSdlGpuTextureLocation = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTextureLocation;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture used in the copy operation.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The mip level index of the location.
    /// </summary>
    property MipLevel: Integer read FHandle.mip_level write FHandle.mip_level;

    /// <summary>
    ///  The layer index of the location.
    /// </summary>
    property Layer: Integer read FHandle.layer write FHandle.layer;

    /// <summary>
    ///  The left offset of the location.
    /// </summary>
    property X: Integer read FHandle.x write FHandle.x;

    /// <summary>
    ///  The top offset of the location.
    /// </summary>
    property Y: Integer read FHandle.y write FHandle.y;

    /// <summary>
    ///  The front offset of the location.
    /// </summary>
    property Z: Integer read FHandle.z write FHandle.z;
  end;

  /// <summary>
  ///  A record specifying a region of a texture.
  ///
  ///  Used when transferring data to or from a texture.
  /// </summary>
  /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
  /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
  /// <seealso cref="TSdlGpuTexture"/>
  TSdlGpuTextureRegion = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTextureRegion;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture used in the copy operation.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The mip level index to transfer.
    /// </summary>
    property MipLevel: Integer read FHandle.mip_level write FHandle.mip_level;

    /// <summary>
    ///  The layer index to transfer.
    /// </summary>
    property Layer: Integer read FHandle.layer write FHandle.layer;

    /// <summary>
    ///  The left offset of the region.
    /// </summary>
    property X: Integer read FHandle.x write FHandle.x;

    /// <summary>
    ///  The top offset of the region.
    /// </summary>
    property Y: Integer read FHandle.y write FHandle.y;

    /// <summary>
    ///  The front offset of the region.
    /// </summary>
    property Z: Integer read FHandle.z write FHandle.z;

    /// <summary>
    ///  The width of the region.
    /// </summary>
    property W: Integer read FHandle.w write FHandle.w;

    /// <summary>
    ///  The height of the region.
    /// </summary>
    property H: Integer read FHandle.h write FHandle.h;

    /// <summary>
    ///  The depth of the region.
    /// </summary>
    property D: Integer read FHandle.d write FHandle.d;
  end;

  /// <summary>
  ///  A record specifying a region of a texture used in the blit operation.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.Blit"/>
  TSdlGpuBlitRegion = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBlitRegion;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The mip level index of the region.
    /// </summary>
    property MipLevel: Integer read FHandle.mip_level write FHandle.mip_level;

    /// <summary>
    ///  The layer index or depth plane of the region. This value is treated as
    ///  a layer index on 2D array and cube textures, and as a depth plane on 3D
    //   textures.
    /// </summary>
    property LayerOrDepthPlane: Integer read FHandle.layer_or_depth_plane write FHandle.layer_or_depth_plane;

    /// <summary>
    ///  The left offset of the region.
    /// </summary>
    property X: Integer read FHandle.x write FHandle.x;

    /// <summary>
    ///  The top offset of the region.
    /// </summary>
    property Y: Integer read FHandle.y write FHandle.y;

    /// <summary>
    ///  The width of the region.
    /// </summary>
    property W: Integer read FHandle.w write FHandle.w;

    /// <summary>
    ///  The height of the region.
    /// </summary>
    property H: Integer read FHandle.h write FHandle.h;
  end;
  PSdlGpuBlitRegion = ^TSdlGpuBlitRegion;

type
  /// <summary>
  ///  A record containing parameters for a blit command.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.Blit"/>
  TSdlGpuBlitInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUBlitInfo;
    function GetSource: PSdlGpuBlitRegion; inline;
    function GetDestination: PSdlGpuBlitRegion; inline;
    function GetLoadOp: TSdlGpuLoadOp; inline;
    procedure SetLoadOp(const AValue: TSdlGpuLoadOp); inline;
    function GetClearColor: TSdlColorF; inline;
    procedure SetClearColor(const AValue: TSdlColorF); inline;
    function GetFlipMode: TSdlFlipMode; inline;
    procedure SetFlipMode(const AValue: TSdlFlipMode); inline;
    function GetFilter: TSdlGpuFilter; inline;
    procedure SetFilter(const AValue: TSdlGpuFilter); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The source region for the blit.
    /// </summary>
    property Source: PSdlGpuBlitRegion read GetSource;

    /// <summary>
    ///  The destination region for the blit.
    /// </summary>
    property Destination: PSdlGpuBlitRegion read GetDestination;

    /// <summary>
    ///  What is done with the contents of the destination before the blit.
    /// </summary>
    property LoadOp: TSdlGpuLoadOp read GetLoadOp write SetLoadOp;

    /// <summary>
    ///  The color to clear the destination region to before the blit.
    ///  Ignored if LoadOp is not TSdlGpuLoadOp.Clear.
    /// </summary>
    property ClearColor: TSdlColorF read GetClearColor write SetClearColor;

    /// <summary>
    ///  The flip mode for the source region.
    /// </summary>
    property FlipMode: TSdlFlipMode read GetFlipMode write SetFlipMode;

    /// <summary>
    ///  The filter mode used when blitting.
    /// </summary>
    property Filter: TSdlGpuFilter read GetFilter write SetFilter;

    /// <summary>
    ///  true cycles the destination texture if it is already bound.
    /// </summary>
    property Cycle: Boolean read FHandle.cycle write FHandle.cycle;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a color target used by a render
  ///  pass.
  ///
  ///  The LoadOp field determines what is done with the texture at the beginning
  ///  of the render pass.
  ///
  ///  - Load: Loads the data currently in the texture. Not recommended for
  ///    multisample textures as it requires significant memory bandwidth.
  ///  - Clear: Clears the texture to a single color.
  ///  - DontCare: The driver will do whatever it wants with the texture memory.
  ///    This is a good option if you know that every single pixel will be touched
  ///    in the render pass.
  ///
  ///  The StoreOp field determines what is done with the color results of the
  ///  render pass.
  ///
  ///  - Store: Stores the results of the render pass in the texture. Not
  ///    recommended for multisample textures as it requires significant memory
  ///    bandwidth.
  ///  - DontCare: The driver will do whatever it wants with the texture memory.
  ///    This is often a good option for depth/stencil textures.
  ///  - Resolve: Resolves a multisample texture into resolve_texture, which must
  ///    have a sample count of 1. Then the driver may discard the multisample
  ///    texture memory. This is the most performant method of resolving a
  ///    multisample target.
  ///  - ResolveAndStore: Resolves a multisample texture into the ResolveTexture,
  ///    which must have a sample count of 1. Then the driver stores the
  ///    multisample texture's contents. Not recommended as it requires
  ///    significant memory bandwidth.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginRenderPass"/>
  TSdlGpuColorTargetInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUColorTargetInfo;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
    function GetClearColor: TSdlColorF; inline;
    procedure SetClearColor(const AValue: TSdlColorF); inline;
    function GetLoadOp: TSdlGpuLoadOp; inline;
    procedure SetLoadOp(const AValue: TSdlGpuLoadOp); inline;
    function GetStoreOp: TSdlGpuStoreOp; inline;
    procedure SetStoreOp(const AValue: TSdlGpuStoreOp); inline;
    function GetResolveTexture: TSdlGpuTexture; inline;
    procedure SetResolveTexture(const AValue: TSdlGpuTexture); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture that will be used as a color target by a render pass.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The mip level to use as a color target.
    /// </summary>
    property MipLevel: Integer read FHandle.mip_level write FHandle.mip_level;

    /// <summary>
    ///  The layer index or depth plane to use as a color target. This value is
    ///  treated as a layer index on 2D array and cube textures, and as a depth
    ///  plane on 3D textures.
    /// </summary>
    property LayerOrDepthPlane: Integer read FHandle.layer_or_depth_plane write FHandle.layer_or_depth_plane;

    /// <summary>
    ///  The color to clear the color target to at the start of the render pass.
    ///  Ignored if TSdlGpuLoadOp.Clear is not used.
    /// </summary>
    property ClearColor: TSdlColorF read GetClearColor write SetClearColor;

    /// <summary>
    ///  What is done with the contents of the color target at the beginning of
    ///  the render pass.
    /// </summary>
    property LoadOp: TSdlGpuLoadOp read GetLoadOp write SetLoadOp;

    /// <summary>
    ///  What is done with the results of the render pass.
    /// </summary>
    property StoreOp: TSdlGpuStoreOp read GetStoreOp write SetStoreOp;

    /// <summary>
    ///  The texture that will receive the results of a multisample resolve
    ///  operation. Ignored if a Resolve* StoreOp is not used.
    /// </summary>
    property ResolveTexture: TSdlGpuTexture read GetResolveTexture write SetResolveTexture;

    /// <summary>
    ///  The mip level of the resolve texture to use for the resolve operation.
    ///  Ignored if a Resolve* StoreOp is not used.
    /// </summary>
    property ResolveMipLevel: Integer read FHandle.resolve_mip_level write FHandle.resolve_mip_level;

    /// <summary>
    ///  The layer index of the resolve texture to use for the resolve operation.
    ///  Ignored if a Resolve* StoreOp is not used.
    /// </summary>
    property ResolveLayer: Integer read FHandle.resolve_layer write FHandle.resolve_layer;

    /// <summary>
    ///  True cycles the texture if the texture is bound and LoadOp is not Load.
    /// </summary>
    property Cycle: Boolean read FHandle.cycle write FHandle.cycle;

    /// <summary>
    ///  True cycles the resolve texture if the resolve texture is bound.
    ///  Ignored if a Resolve* StoreOp is not used.
    /// </summary>
    property CycleResolveTexture: Boolean read FHandle.cycle_resolve_texture write FHandle.cycle_resolve_texture;
  end;

type
  /// <summary>
  ///  A structure specifying the parameters of a depth-stencil target used by a
  ///  render pass.
  ///
  ///  The LoadOp field determines what is done with the depth contents of the
  ///  texture at the beginning of the render pass.
  ///
  ///  - Load: Loads the depth values currently in the texture.
  ///  - Clear: Clears the texture to a single depth.
  ///  - DontCare: The driver will do whatever it wants with the memory. This is
  ///    a good option if you know that every single pixel will be touched in the
  ///    render pass.
  ///
  ///  The StoreOp field determines what is done with the depth results of the
  ///  render pass.
  ///
  ///  - Store: Stores the depth results in the texture.
  ///  - DontCare: The driver will do whatever it wants with the depth results.
  ///    This is often a good option for depth/stencil textures that don't need to
  ///    be reused again.
  ///
  ///  The StencilLoadOp field determines what is done with the stencil contents
  ///  of the texture at the beginning of the render pass.
  ///
  ///  - Load: Loads the stencil values currently in the texture.
  ///  - Clear: Clears the stencil values to a single value.
  ///  - DontCare: The driver will do whatever it wants with the memory. This is
  ///    a good option if you know that every single pixel will be touched in the
  ///    render pass.
  ///
  ///  The StencilStoreOp field determines what is done with the stencil results
  ///  of the render pass.
  ///
  ///  - Store: Stores the stencil results in the texture.
  ///  - DontCare: The driver will do whatever it wants with the stencil results.
  ///    This is often a good option for depth/stencil textures that don't need to
  ///    be reused again.
  ///
  ///  Note that depth/stencil targets do not support multisample resolves.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginRenderPass"/>
  TSdlGpuDepthStencilTargetInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUDepthStencilTargetInfo;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
    function GetLoadOp: TSdlGpuLoadOp; inline;
    procedure SetLoadOp(const AValue: TSdlGpuLoadOp); inline;
    function GetStoreOp: TSdlGpuStoreOp; inline;
    procedure SetStoreOp(const AValue: TSdlGpuStoreOp); inline;
    function GetStencilLoadOp: TSdlGpuLoadOp; inline;
    procedure SetStencilLoadOp(const AValue: TSdlGpuLoadOp); inline;
    function GetStencilStoreOp: TSdlGpuStoreOp; inline;
    procedure SetStencilStoreOp(const AValue: TSdlGpuStoreOp); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture that will be used as the depth stencil target by the render pass.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The value to clear the depth component to at the beginning of the
    ///  render pass. Ignored if TSdlGpuLoadOp.Clear is not used.
    /// </summary>
    property ClearDepth: Single read FHandle.clear_depth write FHandle.clear_depth;

    /// <summary>
    ///  What is done with the depth contents at the beginning of the render pass.
    /// </summary>
    property LoadOp: TSdlGpuLoadOp read GetLoadOp write SetLoadOp;

    /// <summary>
    ///  What is done with the depth results of the render pass.
    /// </summary>
    property StoreOp: TSdlGpuStoreOp read GetStoreOp write SetStoreOp;

    /// <summary>
    ///  What is done with the stencil contents at the beginning of the render pass.
    /// </summary>
    property StencilLoadOp: TSdlGpuLoadOp read GetStencilLoadOp write SetStencilLoadOp;

    /// <summary>
    ///  What is done with the stencil results of the render pass.
    /// </summary>
    property StencilStoreOp: TSdlGpuStoreOp read GetStencilStoreOp write SetStencilStoreOp;

    /// <summary>
    ///  True cycles the texture if the texture is bound and any load ops are
    ///  not Load.
    /// </summary>
    property Cycle: Boolean read FHandle.cycle write FHandle.cycle;

    /// <summary>
    ///  The value to clear the stencil component to at the beginning of the
    ///  render pass. Ignored if TSdlGpuLoadOp.Clear is not used.
    /// </summary>
    property ClearStencil: Byte read FHandle.clear_stencil write FHandle.clear_stencil;
  end;

type
  /// <summary>
  ///  A record specifying parameters related to binding textures in a compute
  ///  pass.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginComputePass"/>
  TSdlGpuStorageTextureReadWriteBinding = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUStorageTextureReadWriteBinding;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture to bind. Must have been created with
    ///  TSdlGpuTextureUsage.ComputeStorageWrite or
    ///  TSdlGpuTextureUsage.ComputeStorageSimultaneousReadWrite.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The mip level index to bind.
    /// </summary>
    property MipLevel: Integer read FHandle.mip_level write FHandle.mip_level;

    /// <summary>
    ///  The layer index to bind.
    /// </summary>
    property Layer: Integer read FHandle.layer write FHandle.layer;

    /// <summary>
    ///  True cycles the texture if it is already bound.
    /// </summary>
    property Cycle: Boolean read FHandle.cycle write FHandle.cycle;
  end;

type
  /// <summary>
  ///  A sampler.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexSamplers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindFragmentSamplers"/>
  TSdlGpuSampler = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUSampler;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuSampler; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuSampler.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuSampler): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuSampler; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuSampler.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuSampler): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuSampler; inline; static;
  end;

type
  /// <summary>
  ///  A record specifying parameters in a sampler binding call.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.BindVertexSamplers"/>
  /// <seealso cref="TSdlGpuRenderPass.BindFragmentSamplers"/>
  TSdlGpuTextureSamplerBinding = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUTextureSamplerBinding;
    function GetTexture: TSdlGpuTexture; inline;
    procedure SetTexture(const AValue: TSdlGpuTexture); inline;
    function GetSampler: TSdlGpuSampler; inline;
    procedure SetSampler(const AValue: TSdlGpuSampler); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The texture to bind. Must have been created with
    ///  TSdlGpuTextureUsage.Sampler.
    /// </summary>
    property Texture: TSdlGpuTexture read GetTexture write SetTexture;

    /// <summary>
    ///  The sampler to bind.
    /// </summary>
    property Sampler: TSdlGpuSampler read GetSampler write SetSampler;
  end;

type
  /// <summary>
  ///  A compiled shader object.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  TSdlGpuShader = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUShader;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuShader; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuShader.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuShader): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuShader; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuShader.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuShader): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuShader; inline; static;
  end;

type
  /// <summary>
  ///  A record specifying the parameters of a graphics pipeline state.
  /// </summary>
  /// <seealso cref="TSdlGpuGraphicsPipeline"/>
  /// <seealso cref="TSdlGpuShader"/>
  /// <seealso cref="TSdlGpuVertexInputState"/>
  /// <seealso cref="TSdlGpuPrimitiveType"/>
  /// <seealso cref="TSdlGpuRasterizerState"/>
  /// <seealso cref="TSdlGpuMultisampleState"/>
  /// <seealso cref="TSdlGpuDepthStencilState"/>
  /// <seealso cref="TSdlGpuGraphicsPipelineTargetInfo"/>
  TSdlGpuGraphicsPipelineCreateInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUGraphicsPipelineCreateInfo;
    FColorTargetDescriptions: TArray<TSdlGpuColorTargetDescription>;   // Keep alive
    FVertexBufferDescriptions: TArray<TSdlGpuVertexBufferDescription>; // Keep alive
    FVertexAttributes: TArray<TSdlGpuVertexAttribute>;                 // Keep alive
    function GetVertexShader: TSdlGpuShader; inline;
    procedure SetVertexShader(const AValue: TSdlGpuShader); inline;
    function GetFragmentShader: TSdlGpuShader; inline;
    procedure SetFragmentShader(const AValue: TSdlGpuShader); inline;
    function GetVertexInputState: TSdlGpuVertexInputState; inline;
    procedure SetVertexInputState(const AValue: TSdlGpuVertexInputState); inline;
    function GetPrimitiveType: TSdlGpuPrimitiveType; inline;
    procedure SetPrimitiveType(const AValue: TSdlGpuPrimitiveType); inline;
    function GetRasterizerState: PSdlGpuRasterizerState; inline;
    function GetMultisampleState: PSdlGpuMultisampleState; inline;
    function GetDepthStencilState: PSdlGpuDepthStencilState; inline;
    function GetTargetInfo: TSdlGpuGraphicsPipelineTargetInfo; inline;
    procedure SetTargetInfo(const AValue: TSdlGpuGraphicsPipelineTargetInfo); inline;
    function GetProps: TSdlProperties; inline;
    procedure SetProps(const AValue: TSdlProperties); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create with default values.
    /// </summary>
    class function Create: TSdlGpuGraphicsPipelineCreateInfo; inline; static;

    /// <summary>
    ///  Init with default values.
    /// </summary>
    procedure Init; inline;

    /// <summary>
    ///  The vertex shader used by the graphics pipeline.
    /// </summary>
    property VertexShader: TSdlGpuShader read GetVertexShader write SetVertexShader;

    /// <summary>
    ///  The fragment shader used by the graphics pipeline.
    /// </summary>
    property FragmentShader: TSdlGpuShader read GetFragmentShader write SetFragmentShader;

    /// <summary>
    ///  The vertex layout of the graphics pipeline.
    /// </summary>
    property VertexInputState: TSdlGpuVertexInputState read GetVertexInputState write SetVertexInputState;

    /// <summary>
    ///  The primitive topology of the graphics pipeline.
    /// </summary>
    property PrimitiveType: TSdlGpuPrimitiveType read GetPrimitiveType write SetPrimitiveType;

    /// <summary>
    ///  The rasterizer state of the graphics pipeline.
    /// </summary>
    property RasterizerState: PSdlGpuRasterizerState read GetRasterizerState;

    /// <summary>
    ///  The multisample state of the graphics pipeline.
    /// </summary>
    property MultisampleState: PSdlGpuMultisampleState read GetMultisampleState;

    /// <summary>
    ///  The depth-stencil state of the graphics pipeline.
    /// </summary>
    property DepthStencilState: PSdlGpuDepthStencilState read GetDepthStencilState;

    /// <summary>
    ///  Formats and blend modes for the render targets of the graphics pipeline.
    /// </summary>
    property TargetInfo: TSdlGpuGraphicsPipelineTargetInfo read GetTargetInfo write SetTargetInfo;

    /// <summary>
    ///  A properties ID for extensions. Should be nil if no extensions are needed.
    /// </summary>
    property Props: TSdlProperties read GetProps write SetProps;
  end;
  PSdlGpuGraphicsPipelineCreateInfo = ^TSdlGpuGraphicsPipelineCreateInfo;

type
  /// <summary>
  ///  A graphics pipeline. Used during render passes.
  /// </summary>
  /// <seealso cref="TSdlGpuRenderPass.BindPipeline"/>
  /// <remarks>
  ///  This struct is available since SDL 3.2.0.
  /// </remarks>
  TSdlGpuGraphicsPipeline = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUGraphicsPipeline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuGraphicsPipeline; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuGraphicsPipeline.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuGraphicsPipeline): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuGraphicsPipeline; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuGraphicsPipeline.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuGraphicsPipeline): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuGraphicsPipeline; inline; static;
  end;

type
  /// <summary>
  ///  A GPU driver compiled into SDL.
  /// </summary>
  TSdlGpuDriver = record
  {$REGION 'Internal Declarations'}
  private
    FName: PUTF8Char;
    function GetName: String; inline;
    class function GetCount: Integer; inline; static;
    class function GetDriver(const AIndex: Integer): TSdlGpuDriver; inline; static;
    class function GetDefault: TSdlGpuDriver; inline; static;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Checks for GPU runtime support.
    /// </summary>
    /// <param name="AFormats">Which shader formats the app is able to provide.</param>
    /// <returns>True if supported, False otherwise.</returns>
    /// <seealso cref="TSdlGpuDevice"/>
    function SupportsFormats(const AFormats: TSdlGpuShaderFormats): Boolean; inline;

    /// <summary>
    ///  Checks for GPU runtime support.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <returns>True if supported, False otherwise.</returns>
    /// <seealso cref="TSdlGpuDevice"/>
    class function SupportsProperties(const AProps: TSdlProperties): Boolean; inline; static;

    /// <summary>
    ///  Get the name of a built in GPU driver.
    ///
    ///  The GPU drivers are presented in the order in which they are normally
    ///  checked during initialization.
    ///
    ///  The names of drivers are all simple, low-ASCII identifiers, like "vulkan",
    ///  "metal" or "direct3d12". These never have Unicode characters, and are not
    ///  meant to be proper names.
    ///
    ///  Note that the default driver (Default) does not have a name.
    /// </summary>
    /// <seealso cref="Default"/>
    property Name: String read GetName;

    /// <summary>
    ///  The number of GPU drivers compiled into SDL.
    /// </summary>
    /// <seealso cref="Drivers"/>
    class property Count: Integer read GetCount;

    /// <summary>
    ///  The GPU drivers compiled into SDL.
    /// </summary>
    /// <seealso cref="Count"/>
    class property Drivers[const AIndex: Integer]: TSdlGpuDriver read GetDriver; default;

    /// <summary>
    ///  The default GPU driver.
    ///  This driver does not have a name.
    /// </summary>
    class property Default: TSdlGpuDriver read GetDefault;
  end;

type
  /// <summary>
  ///  A render pass.
  ///
  ///  This handle is transient and should not be held or referenced after
  ///  Finish is called.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginRenderPass"/>
  TSdlGpuRenderPass = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPURenderPass;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuRenderPass; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuRenderPass.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuRenderPass): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuRenderPass; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuRenderPass.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuRenderPass): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuRenderPass; inline; static;
  public
    /// <summary>
    ///  Ends the render pass.
    ///
    ///  All bound graphics state on the render pass command buffer is unset. The
    ///  render pass is now invalid.
    /// </summary>
    procedure Finish; inline;

    /// <summary>
    ///  Sets the current viewport state on a command buffer.
    /// </summary>
    /// <param name="AViewport">The viewport to set.</param>
    procedure SetViewport(const AViewport: TSdlGpuViewport); inline;

    /// <summary>
    ///  Sets the current scissor state on a command buffer.
    /// </summary>
    /// <param name="AScissor">The scissor area to set.</param>
    procedure SetScissor(const AScissor: TSdlRect); inline;

    /// <summary>
    ///  Sets the current blend constants on a command buffer.
    ///  Used with `TSdlGpuBlendFactor.ConstantColor` and 
    ///  `TSdlGpuBlendFactor.OneMinusConstantColor`.
    /// </summary>
    /// <param name="ABlendConstants">The blend constant color.</param>
    /// <seealso cref="TSdlGpuBlendFactor"/>
    procedure SetBlendConstants(const ABlendConstants: TSdlColorF); inline;

    /// <summary>
    ///  Sets the current stencil reference value on a command buffer.
    /// </summary>
    /// <param name="AReference">The stencil reference value to set.</param>
    procedure SetStencilReference(const AReference: Byte); inline;

    /// <summary>
    ///  Binds a graphics pipeline on a render pass to be used in rendering.
    ///
    ///  A graphics pipeline must be bound before making any draw calls.
    /// </summary>
    /// <param name="AGraphicsPipeline">The graphics pipeline to bind.</param>
    procedure BindPipeline(const AGraphicsPipeline: TSdlGpuGraphicsPipeline); inline;

    /// <summary>
    ///  Binds vertex buffers on a command buffer for use with subsequent draw
    ///  calls.
    /// </summary>
    /// <param name="AFirstSlot">The vertex buffer slot to begin binding from.</param>
    /// <param name="ABindings">An array of TSdlGpuBufferBinding records
    ///  containing vertex buffers and offset values.</param>
    procedure BindVertexBuffers(const AFirstSlot: Integer;
      const ABindings: TArray<TSdlGpuBufferBinding>); inline;

    /// <summary>
    ///  Binds an index buffer on a command buffer for use with subsequent draw
    ///  calls.
    /// </summary>
    /// <param name="ABinding">A record containing an index buffer and offset.</param>
    /// <param name="AIndexElementSize">Whether the index values in the buffer
    ///  are 16- or 32-bit.</param>
    procedure BindIndexBuffer(const ABinding: TSdlGpuBufferBinding;
      const AIndexElementSize: TSdlGpuIndexElementSize); inline;

    /// <summary>
    ///  Binds texture-sampler pairs for use on the vertex shader.
    ///
    ///  The textures must have been created with TSdlGpuTextureUsage.Sampler.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The vertex sampler slot to begin binding from.</param>
    /// <param name="ATextureSamplerBindings">An array of texture-sampler binding
    ///  records.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindVertexSamplers(const AFirstSlot: Integer;
      const ATextureSamplerBindings: TArray<TSdlGpuTextureSamplerBinding>); inline;

    /// <summary>
    ///  Binds storage textures for use on the vertex shader.
    ///
    ///  These textures must have been created with
    ///  TSdlGpuTextureUsage.GraphicsStorageRead.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The vertex storage texture slot to begin binding from.</param>
    /// <param name="AStorageTextures">An array of storage textures.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindVertexStorageTextures(const AFirstSlot: Integer;
      const AStorageTextures: TArray<TSdlGpuTexture>); inline;

    /// <summary>
    ///  Binds storage buffers for use on the vertex shader.
    ///
    ///  These buffers must have been created with
    ///  TSdlGpuBufferUsage.GraphicsStorageRead.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The vertex storage buffer slot to begin binding from.</param>
    /// <param name="AStorageBuffers">An array of buffers.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindVertexStorageBuffers(const AFirstSlot: Integer;
      const AStorageBuffers: TArray<TSdlGpuBuffer>); inline;

    /// <summary>
    ///  Binds texture-sampler pairs for use on the fragment shader.
    ///
    ///  The textures must have been created with TSdlGpuTextureUsage.Sampler.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The fragment sampler slot to begin binding from.</param>
    /// <param name="ATextureSamplerBindings">An array of texture-sampler
    ///  binding records.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindFragmentSamplers(const AFirstSlot: Integer;
      const ATextureSamplerBindings: TArray<TSdlGpuTextureSamplerBinding>); inline;

    /// <summary>
    ///  Binds storage textures for use on the fragment shader.
    ///
    ///  These textures must have been created with
    ///  TSdlGpuTextureUsage.GraphicsStorageRead.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The fragment storage texture slot to begin binding from.</param>
    /// <param name="AStorageTextures">An array of storage textures.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindFragmentStorageTextures(const AFirstSlot: Integer;
      const AStorageTextures: TArray<TSdlGpuTexture>); inline;

    /// <summary>
    ///  Binds storage buffers for use on the fragment shader.
    ///
    ///  These buffers must have been created with
    ///  TSdlGpuBufferUsage.GraphicsStorageRead.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The fragment storage buffer slot to begin binding from.</param>
    /// <param name="AStorageBuffers">An array of storage buffers.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindFragmentStorageBuffers(const AFirstSlot: Integer;
      const AStorageBuffers: TArray<TSdlGpuBuffer>); inline;

    /// <summary>
    ///  Draws data using bound graphics state.
    ///
    ///  You must not call this method before binding a graphics pipeline.
    ///
    ///  Note that the `AFirstVertex` and `AFirstInstance` parameters are NOT
    ///  compatible with built-in vertex/instance ID variables in shaders (for
    ///  example, SV_VertexID); GPU APIs and shader languages do not define these
    ///  built-in variables consistently, so if your shader depends on them, the
    ///  only way to keep behavior consistent and portable is to always pass 0 for
    ///  the correlating parameter in the draw calls.
    /// </summary>
    /// <param name="ANumVertices">The number of vertices to draw.</param>
    /// <param name="ANumInstances">The number of instances that will be drawn.</param>
    /// <param name="AFirstVertex">The index of the first vertex to draw.</param>
    /// <param name="AFirstInstance">The ID of the first instance to draw.</param>
    procedure DrawPrimitives(const ANumVertices, ANumInstances, AFirstVertex,
      AFirstInstance: Integer); overload; inline;

    /// <summary>
    ///  Draws data using bound graphics state and with draw parameters set from a
    ///  buffer.
    ///
    ///  The buffer must consist of tightly-packed draw parameter sets that each
    ///  match the layout of TSdlGpuIndirectDrawCommand. You must not call this
    ///  method before binding a graphics pipeline.
    /// </summary>
    /// <param name="ABuffer">A buffer containing draw parameters.</param>
    /// <param name="AOffset">The offset to start reading from the draw buffer.</param>
    /// <param name="ADrawCount">The number of draw parameter sets that should
    ///  be read from the draw buffer.</param>
    procedure DrawPrimitives(const ABuffer: TSdlGpuBuffer;
      const AOffset, ADrawCount: Integer); overload; inline;

    /// <summary>
    ///  Draws data using bound graphics state with an index buffer and instancing
    ///  enabled.
    ///
    ///  You must not call this method before binding a graphics pipeline.
    ///
    ///  Note that the `AFirstVertex` and `AFirstInstance` parameters are NOT
    ///  compatible with built-in vertex/instance ID variables in shaders (for
    ///  example, SV_VertexID); GPU APIs and shader languages do not define these
    ///  built-in variables consistently, so if your shader depends on them, the
    ///  only way to keep behavior consistent and portable is to always pass 0 for
    ///  the correlating parameter in the draw calls.
    /// </summary>
    /// <param name="ANumIndices">The number of indices to draw per instance.</param>
    /// <param name="ANumInstances">The number of instances to draw.</param>
    /// <param name="AFirstIndex">The starting index within the index buffer.</param>
    /// <param name="AVertexOffset">Value added to vertex index before indexing
    ///  into the vertex buffer.</param>
    /// <param name="AFirstInstance">The ID of the first instance to draw.</param>
    procedure DrawIndexedPrimitives(const ANumIndices, ANumInstances, AFirstIndex,
      AVertexOffset, AFirstInstance: Integer); overload; inline;

    /// <summary>
    ///  Draws data using bound graphics state with an index buffer enabled and with
    ///  draw parameters set from a buffer.
    ///
    ///  The buffer must consist of tightly-packed draw parameter sets that each
    ///  match the layout of TSdlGpuIndexedIndirectDrawCommand. You must not call
    ///  this method before binding a graphics pipeline.
    /// </summary>
    /// <param name="ABuffer">A buffer containing draw parameters.</param>
    /// <param name="AOffset">The offset to start reading from the draw buffer.</param>
    /// <param name="ADrawCount">The number of draw parameter sets that should
    ///  be read from the draw buffer.</param>
    /// <remarks>
    ///  This function is available since SDL 3.2.0.
    /// </remarks>
    procedure DrawIndexedPrimitives(const ABuffer: TSdlGpuBuffer;
      const AOffset, ADrawCount: Integer); overload; inline;
  end;

type
  /// <summary>
  ///  A compute pass.
  ///
  ///  This handle is transient and should not be held or referenced after
  ///  Finish is called.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginComputePass"/>
  TSdlGpuComputePass = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUComputePass;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuComputePass; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuComputePass.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuComputePass): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuComputePass; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuComputePass.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuComputePass): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuComputePass; inline; static;
  public
    /// <summary>
    ///  Ends the current compute pass.
    ///
    ///  All bound compute state on the command buffer is unset. The compute pass
    ///  handle is now invalid.
    /// </summary>
    procedure Finish; inline;

    /// <summary>
    ///  Binds a compute pipeline on a command buffer for use in compute dispatch.
    /// </summary>
    /// <param name="AComputePipeline">A compute pipeline to bind.</param>
    procedure BindPipeline(const AComputePipeline: TSdlGpuComputePipeline); inline;

    /// <summary>
    ///  Binds texture-sampler pairs for use on the compute shader.
    ///
    ///  The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The compute sampler slot to begin binding from.</param>
    /// <param name="ATextureSamplerBindings">An array of texture-sampler
    ///  binding record.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindSamplers(const AFirstSlot: Integer;
      const ATextureSamplerBindings: TArray<TSdlGpuTextureSamplerBinding>); inline;

    /// <summary>
    ///  Binds storage textures as readonly for use on the compute pipeline.
    ///
    ///  These textures must have been created with
    ///  TSdlGpuTextureUsage.ComputeStorageRead.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The compute storage texture slot to begin binding from.</param>
    /// <param name="AStorageTextures">An array of storage textures.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindStorageTextures(const AFirstSlot: Integer;
      const AStorageTextures: TArray<TSdlGpuTexture>); inline;

    /// <summary>
    ///  Binds storage buffers as readonly for use on the compute pipeline.
    ///
    ///  These buffers must have been created with
    ///  TSdlGpuBufferUsage.ComputeStorageRead.
    ///
    ///  Be sure your shader is set up according to the requirements documented
    ///  TSdlGpuShader.
    /// </summary>
    /// <param name="AFirstSlot">The compute storage buffer slot to begin binding from.</param>
    /// <param name="AStorageBuffers">An array of storage buffer binding records.</param>
    /// <seealso cref="TSdlGpuShader"/>
    procedure BindStorageBuffers(const AFirstSlot: Integer;
      const AStorageBuffers: TArray<TSdlGpuBuffer>); inline;

    /// <summary>
    ///  Dispatches compute work.
    ///
    ///  You must not call this method before binding a compute pipeline.
    ///
    ///  A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
    ///  the dispatches write to the same resource region as each other, there is no
    ///  guarantee of which order the writes will occur. If the write order matters,
    ///  you MUST end the compute pass and begin another one.
    /// </summary>
    /// <param name="AGroupCountX">Number of local workgroups to dispatch in
    ///  the X dimension.</param>
    /// <param name="AGroupCountY">Number of local workgroups to dispatch in
    ///  the Y dimension.</param>
    /// <param name="AGroupCountZ">Number of local workgroups to dispatch in
    ///  the Z dimension.</param>
    procedure Dispatch(const AGroupCountX, AGroupCountY, AGroupCountZ: Integer); overload; inline;

    /// <summary>
    ///  Dispatches compute work with parameters set from a buffer.
    ///
    ///  The buffer layout should match the layout of
    ///  TSdlGpuIndirectDispatchCommand. You must not call this method before
    ///  binding a compute pipeline.
    ///
    ///  A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
    ///  the dispatches write to the same resource region as each other, there is no
    ///  guarantee of which order the writes will occur. If the write order matters,
    ///  you MUST end the compute pass and begin another one.
    /// </summary>
    /// <param name="ABuffer">A buffer containing dispatch parameters.</param>
    /// <param name="AOffset">The offset to start reading from the dispatch buffer.</param>
    procedure Dispatch(const ABuffer: TSdlGpuBuffer; const AOffset: Integer); overload; inline;
  end;

type
  /// <summary>
  ///  A copy pass.
  ///
  ///  This handle is transient and should not be held or referenced after
  ///  Finish is called.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.BeginCopyPass"/>
  TSdlGpuCopyPass = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUCopyPass;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuCopyPass; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuCopyPass.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuCopyPass): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuCopyPass; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuCopyPass.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuCopyPass): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuCopyPass; inline; static;
  public
    /// <summary>
    ///  Ends the current copy pass.
    /// </summary>
    procedure Finish; inline;

    /// <summary>
    ///  Uploads data from a transfer buffer to a texture.
    ///
    ///  The upload occurs on the GPU timeline. You may assume that the upload has
    ///  finished in subsequent commands.
    ///
    ///  You must align the data in the transfer buffer to a multiple of the texel
    ///  size of the texture format.
    /// </summary>
    /// <param name="ASource">The source transfer buffer with image layout information.</param>
    /// <param name="ADestination">The destination texture region.</param>
    /// <param name="ACycle">If true, cycles the texture if the texture is
    ///  bound, otherwise overwrites the data.</param>
    procedure UploadToTexture(const ASource: TSdlGpuTextureTransferInfo;
      const ADestination: TSdlGpuTextureRegion; const ACycle: Boolean); inline;

    /// <summary>
    ///  Uploads data from a transfer buffer to a buffer.
    ///
    ///  The upload occurs on the GPU timeline. You may assume that the upload has
    ///  finished in subsequent commands.
    /// </summary>
    /// <param name="ASource">The source transfer buffer with offset.</param>
    /// <param name="ADestination">The destination buffer with offset and size.</param>
    /// <param name="ACycle">If true, cycles the buffer if it is already bound,
    ///  otherwise overwrites the data.</param>
    procedure UploadToBuffer(const ASource: TSdlGpuTransferBufferLocation;
      const ADestination: TSdlGpuBufferRegion; const ACycle: Boolean); inline;

    /// <summary>
    ///  Performs a texture-to-texture copy.
    ///
    ///  This copy occurs on the GPU timeline. You may assume the copy has finished
    ///  in subsequent commands.
    /// </summary>
    /// <param name="ASource">A source texture region.</param>
    /// <param name="ADestination">A destination texture region.</param>
    /// <param name="AW">The width of the region to copy.</param>
    /// <param name="AH">The height of the region to copy.</param>
    /// <param name="AD">The depth of the region to copy.</param>
    /// <param name="ACycle">If True, cycles the destination texture if the
    ///  destination texture is bound, otherwise overwrites the data.</param>
    procedure CopyTextureToTexture(const ASource,
      ADestination: TSdlGpuTextureLocation; const AW, AH, AD: Integer;
      const ACycle: Boolean); inline;

    /// <summary>
    ///  Performs a buffer-to-buffer copy.
    ///
    ///  This copy occurs on the GPU timeline. You may assume the copy has finished
    ///  in subsequent commands.
    /// </summary>
    /// <param name="ASource">The buffer and offset to copy from.</param>
    /// <param name="ADestination">The buffer and offset to copy to.</param>
    /// <param name="ASize">The length of the buffer to copy.</param>
    /// <param name="ACycle">If True, cycles the destination buffer if it is
    ///  already bound, otherwise overwrites the data.</param>
    /// <remarks>
    ///  This function is available since SDL 3.2.0.
    /// </remarks>
    procedure CopyBufferToBuffer(const ASource, ADestination: TSdlGpuBufferLocation;
      const ASize: Integer; const ACycle: Boolean); inline;

    /// <summary>
    ///  Copies data from a texture to a transfer buffer on the GPU timeline.
    ///
    ///  This data is not guaranteed to be copied until the command buffer fence is
    ///  signaled.
    /// </summary>
    /// <param name="ASource">The source texture region.</param>
    /// <param name="ADestination">The destination transfer buffer with image
    ///  layout information.</param>
    procedure DownloadFromTexture(const ASource: TSdlGpuTextureRegion;
      const ADestination: TSdlGpuTextureTransferInfo); inline;

    /// <summary>
    ///  Copies data from a buffer to a transfer buffer on the GPU timeline.
    ///
    ///  This data is not guaranteed to be copied until the command buffer fence is
    ///  signaled.
    /// </summary>
    /// <param name="ASource">The source buffer with offset and size.</param>
    /// <param name="ADestination">The destination transfer buffer with offset.</param>
    procedure DownloadFromBuffer(const ASource: TSdlGpuBufferRegion;
      const ADestination: TSdlGpuTransferBufferLocation); inline;
  end;

type
  /// <summary>
  ///  A fence.
  /// </summary>
  /// <seealso cref="TSdlGpuCommandBuffer.SubmitAndAcquireFence"/>
  /// <seealso cref="TSdlGpuDevice.QueryFence"/>
  /// <seealso cref="TSdlGpuDevice.WaitForFences"/>
  /// <seealso cref="TSdlGpuDevice.ReleaseFence"/>
  TSdlGpuFence = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUFence;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuFence; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuFence.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuFence): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuFence; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuFence.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuFence): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuFence; inline; static;
  end;

type
  /// <summary>
  ///  A command buffer.
  ///
  ///  Most state is managed via command buffers. When setting state using a
  ///  command buffer, that state is local to the command buffer.
  ///
  ///  Commands only begin execution on the GPU once Submit is called. Once the
  ///  command buffer is submitted, it is no longer valid to use it.
  ///
  ///  Command buffers are executed in submission order. If you submit command
  ///  buffer A and then command buffer B all commands in A will begin executing
  ///  before any command in B begins executing.
  ///
  ///  In multi-threading scenarios, you should only access a command buffer on
  ///  the thread you acquired it from.
  /// </summary>
  /// <seealso cref="TSdlGpuDevice.AcquireCommandBuffer"/>
  /// <seealso cref="TSdlGpuCommandBuffer.Submit"/>
  /// <seealso cref="TSdlGpuCommandBuffer.SubmitAndAcquireFence"/>
  TSdlGpuCommandBuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUCommandBuffer;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuCommandBuffer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuCommandBuffer.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuCommandBuffer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuCommandBuffer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuCommandBuffer.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuCommandBuffer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuCommandBuffer; inline; static;
  public
    /// <summary>
    ///  Inserts an arbitrary string label into the command buffer callstream.
    ///
    ///  Useful for debugging.
    /// </summary>
    /// <param name="AText">A string constant to insert as the label.</param>
    procedure InsertDebugLabel(const AText: String); inline;

    /// <summary>
    ///  Begins a debug group with an arbitary name.
    ///
    ///  Used for denoting groups of calls when viewing the command buffer
    ///  callstream in a graphics debugging tool.
    ///
    ///  Each call to PushDebugGroup must have a corresponding call to
    ///  PopDebugGroup.
    ///
    ///  On some backends (e.g. Metal), pushing a debug group during a
    ///  render/blit/compute pass will create a group that is scoped to the native
    ///  pass rather than the command buffer. For best results, if you push a debug
    ///  group during a pass, always pop it in the same pass.
    /// </summary>
    /// <param name="AName">A string constant that names the group.</param>
    /// <seealso cref="PopDebugGroup"/>
    procedure PushDebugGroup(const AName: String); inline;

    /// <summary>
    ///  Ends the most-recently pushed debug group.
    /// </summary>
    /// <seealso cref="PushDebugGroup"/>
    procedure PopDebugGroup; inline;

    /// <summary>
    ///  Pushes data to a vertex uniform slot on the command buffer.
    ///
    ///  Subsequent draw calls will use this uniform data.
    ///
    ///  The data being pushed must respect std140 layout conventions. In
    ///  practical terms this means you must ensure that vec3 and vec4 fields
    ///  are 16-byte aligned.
    /// </summary>
    /// <param name="ASlotIndex">The vertex uniform slot to push data to.</param>
    /// <param name="AData">Client data to write.</param>
    procedure PushVertexUniformData(const ASlotIndex: Integer;
      const AData: TBytes); overload; inline;

    /// <summary>
    ///  Pushes data to a vertex uniform slot on the command buffer.
    ///
    ///  Subsequent draw calls will use this uniform data.
    ///
    ///  The data being pushed must respect std140 layout conventions. In
    ///  practical terms this means you must ensure that vec3 and vec4 fields
    ///  are 16-byte aligned.
    /// </summary>
    /// <param name="ASlotIndex">The vertex uniform slot to push data to.</param>
    /// <param name="AData">Pointer to client data to write.</param>
    /// <param name="ASize">Size of the data to write.</param>
    procedure PushVertexUniformData(const ASlotIndex: Integer;
      const AData: Pointer; const ASize: Integer); overload; inline;

    /// <summary>
    ///  Pushes data to a fragment uniform slot on the command buffer.
    ///
    ///  Subsequent draw calls will use this uniform data.
    ///
    ///  The data being pushed must respect std140 layout conventions. In
    ///  practical terms this means you must ensure that vec3 and vec4 fields
    ///  are 16-byte aligned.
    /// </summary>
    /// <param name="ASlotIndex">The fragment uniform slot to push data to.</param>
    /// <param name="AData">Client data to write.</param>
    procedure PushFragmentUniformData(const ASlotIndex: Integer;
      const AData: TBytes); overload; inline;

    /// <summary>
    ///  Pushes data to a fragment uniform slot on the command buffer.
    ///
    ///  Subsequent draw calls will use this uniform data.
    ///
    ///  The data being pushed must respect std140 layout conventions. In
    ///  practical terms this means you must ensure that vec3 and vec4 fields
    ///  are 16-byte aligned.
    /// </summary>
    /// <param name="ASlotIndex">The fragment uniform slot to push data to.</param>
    /// <param name="AData">Pointer to client data to write.</param>
    /// <param name="ASize">Size of the data to write.</param>
    procedure PushFragmentUniformData(const ASlotIndex: Integer;
      const AData: Pointer; const ASize: Integer); overload; inline;

    /// <summary>
    ///  Pushes data to a uniform slot on the command buffer.
    ///
    ///  Subsequent draw calls will use this uniform data.
    ///
    ///  The data being pushed must respect std140 layout conventions. In
    ///  practical terms this means you must ensure that vec3 and vec4 fields
    ///  are 16-byte aligned.
    /// </summary>
    /// <param name="ASlotIndex">The uniform slot to push data to.</param>
    /// <param name="AData">Client data to write.</param>
    procedure PushComputeUniformData(const ASlotIndex: Integer;
      const AData: TBytes); overload; inline;

    /// <summary>
    ///  Pushes data to a uniform slot on the command buffer.
    ///
    ///  Subsequent draw calls will use this uniform data.
    ///
    ///  The data being pushed must respect std140 layout conventions. In
    ///  practical terms this means you must ensure that vec3 and vec4 fields
    ///  are 16-byte aligned.
    /// </summary>
    /// <param name="ASlotIndex">The uniform slot to push data to.</param>
    /// <param name="AData">Pointer to client data to write.</param>
    /// <param name="ASize">Size of the data to write.</param>
    procedure PushComputeUniformData(const ASlotIndex: Integer;
      const AData: Pointer; const ASize: Integer); overload; inline;

    /// <summary>
    ///  Begins a render pass on a command buffer.
    ///
    ///  A render pass consists of a set of texture subresources (or depth slices in
    ///  the 3D texture case) which will be rendered to during the render pass,
    ///  along with corresponding clear values and load/store operations. All
    ///  operations related to graphics pipelines must take place inside of a render
    ///  pass. A default viewport and scissor state are automatically set when this
    ///  is called. You cannot begin another render pass, or begin a compute pass or
    ///  copy pass until you have ended the render pass.
    /// </summary>
    /// <param name="AColorTargetInfos">An array of texture subresources with
    ///  corresponding clear values and load/store ops.</param>
    /// <returns>A render pass.</returns>
    /// <seealso cref="TSdlGpuRenderPass.Finish"/>
    function BeginRenderPass(
      const AColorTargetInfos: TArray<TSdlGpuColorTargetInfo>): TSdlGpuRenderPass; overload; inline;

    /// <summary>
    ///  Begins a render pass on a command buffer.
    ///
    ///  A render pass consists of a set of texture subresources (or depth slices in
    ///  the 3D texture case) which will be rendered to during the render pass,
    ///  along with corresponding clear values and load/store operations. All
    ///  operations related to graphics pipelines must take place inside of a render
    ///  pass. A default viewport and scissor state are automatically set when this
    ///  is called. You cannot begin another render pass, or begin a compute pass or
    ///  copy pass until you have ended the render pass.
    /// </summary>
    /// <param name="AColorTargetInfos">An array of texture subresources with
    ///  corresponding clear values and load/store ops.</param>
    /// <param name="ADepthStencilTargetInfo">Texture subresource with
    ///  corresponding clear value and load/store ops, may be nil.</param>
    /// <returns>A render pass.</returns>
    /// <seealso cref="TSdlGpuRenderPass.Finish"/>
    function BeginRenderPass(const AColorTargetInfos: TArray<TSdlGpuColorTargetInfo>;
      const ADepthStencilTargetInfo: TSdlGpuDepthStencilTargetInfo): TSdlGpuRenderPass; overload; inline;

    /// <summary>
    ///  Begins a compute pass on a command buffer.
    ///
    ///  A compute pass is defined by a set of texture subresources and buffers that
    ///  may be written to by compute pipelines. These textures and buffers must
    ///  have been created with TSdlGpuTextureUsage.ComputeStorageWrite or
    ///  TSdlGpuTextureUsage.ComputeStorageSimultaneousReadWrite. If you do not
    ///  create a texture with TSdlGpuTextureUsage.ComputeStorageSimultaneousReadWrite,
    ///  you must not read from the texture in the compute pass. All operations
    ///  related to compute pipelines must take place inside of a compute pass.
    ///  You must not begin another compute pass, or a render pass or copy pass
    ///  before ending the compute pass.
    ///
    ///  A VERY IMPORTANT NOTE - Reads and writes in compute passes are NOT
    ///  implicitly synchronized. This means you may cause data races by both
    ///  reading and writing a resource region in a compute pass, or by writing
    ///  multiple times to a resource region. If your compute work depends on
    ///  reading the completed output from a previous dispatch, you MUST end the
    ///  current compute pass and begin a new one before you can safely access the
    ///  data. Otherwise you will receive unexpected results. Reading and writing a
    ///  texture in the same compute pass is only supported by specific texture
    ///  formats. Make sure you check the format support!
    /// </summary>
    /// <param name="AStorageTextureBindings">An array of writeable storage
    ///  texture binding records.</param>
    /// <param name="AStorageBufferBindings">An array of writeable storage buffer
    ///  binding records.</param>
    /// <returns>A compute pass.</returns>
    /// <seealso cref="TSdlGpuComputePass.Finish"/>
    function BeginComputePass(
      const AStorageTextureBindings: TArray<TSdlGpuStorageTextureReadWriteBinding>;
      const AStorageBufferBindings: TArray<TSdlGpuStorageBufferReadWriteBinding>): TSdlGpuComputePass; inline;

    /// <summary>
    ///  Begins a copy pass on a command buffer.
    ///
    ///  All operations related to copying to or from buffers or textures take place
    ///  inside a copy pass. You must not begin another copy pass, or a render pass
    ///  or compute pass before ending the copy pass.
    /// </summary>
    /// <returns>A copy pass.</returns>
    function BeginCopyPass: TSdlGpuCopyPass; inline;

    /// <summary>
    ///  Generates mipmaps for the given texture.
    ///
    ///  This function must not be called inside of any pass.
    /// </summary>
    /// <param name="ATexture">A texture with more than 1 mip level.</param>
    procedure GenerateMipmaps(const ATexture: TSdlGpuTexture); inline;

    /// <summary>
    ///  Blits from a source texture region to a destination texture region.
    ///
    ///  This function must not be called inside of any pass.
    /// </summary>
    /// <param name="AInfo">The blit info struct containing the blit parameters.</param>
    procedure Blit(const AInfo: TSdlGpuBlitInfo); inline;

    /// <summary>
    ///  Acquire a texture to use in presentation.
    ///
    ///  When a swapchain texture is acquired on a command buffer, it will
    ///  automatically be submitted for presentation when the command buffer is
    ///  submitted. The swapchain texture should only be referenced by the command
    ///  buffer used to acquire it.
    ///
    ///  This method will fill the swapchain texture handle with nil if too many
    ///  frames are in flight. This is not an error.
    ///
    ///  If you use this method, it is possible to create a situation where many
    ///  command buffers are allocated while the rendering context waits for the GPU
    ///  to catch up, which will cause memory usage to grow. You should use
    ///  WaitAndAcquireSwapchainTexture unless you know what you are doing
    ///  with timing.
    ///
    ///  The swapchain texture is managed by the implementation and must not be
    ///  freed by the user. You MUST NOT call this method from any thread other
    ///  than the one that created the window.
    /// </summary>
    /// <param name="AWindow">A window that has been claimed.</param>
    /// <param name="ASwapchainTexture">Will be set to a swapchain texture.</param>
    /// <param name="ASwapchainTextureWidth">Will be set to the swapchain texture width.</param>
    /// <param name="ASwapchainTextureHeight">Will be set to the swapchain texture height.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuDevice.ClaimWindow"/>
    /// <seealso cref="Submit"/>
    /// <seealso cref="SubmitAndAcquireFence"/>
    /// <seealso cref="Cancel"/>
    /// <seealso cref="TSdlWindow.GetSizeInPixels"/>
    /// <seealso cref="TSdlGpuDevice.WaitForSwapchain"/>
    /// <seealso cref="WaitAndAcquireSwapchainTexture"/>
    /// <seealso cref="TSdlGpuDevice.SetAllowedFramesInFlight"/>
    /// <remarks>
    ///  This method should only be called from the thread that created the window.
    /// </remarks>
    procedure AcquireSwapchainTexture(const AWindow: TSdlWindow;
      out ASwapchainTexture: TSdlGpuTexture; out ASwapchainTextureWidth,
      ASwapchainTextureHeight: Integer); inline;

    /// <summary>
    ///  Blocks the thread until a swapchain texture is available to be acquired,
    ///  and then acquires it.
    ///
    ///  When a swapchain texture is acquired on a command buffer, it will
    ///  automatically be submitted for presentation when the command buffer is
    ///  submitted. The swapchain texture should only be referenced by the command
    ///  buffer used to acquire it. It is an error to call
    ///  Cancel after a swapchain texture is acquired.
    ///
    ///  This method can fill the swapchain texture handle with nil in certain
    ///  cases, for example if the window is minimized. This is not an error. You
    ///  should always make sure to check whether the pointer is nil before
    ///  actually using it.
    ///
    ///  The swapchain texture is managed by the implementation and must not be
    ///  freed by the user. You MUST NOT call this method from any thread other
    ///  than the one that created the window.
    ///
    ///  The swapchain texture is write-only and cannot be used as a sampler or
    ///  for another reading operation.
    /// </summary>
    /// <param name="AWindow">A window that has been claimed.</param>
    /// <param name="ASwapchainTexture">Is set to a swapchain texture.</param>
    /// <param name="ASwapchainTextureWidth">Is set to the swapchain texture width.</param>
    /// <param name="ASwapchainTextureHeight">Is set to the swapchain texture height.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Submit"/>
    /// <seealso cref="SubmitAndAcquireFence"/>
    /// <seealso cref="AcquireSwapchainTexture"/>
    /// <remarks>
    ///  This method should only be called from the thread that created the window.
    /// </remarks>
    procedure WaitAndAcquireSwapchainTexture(const AWindow: TSdlWindow;
      out ASwapchainTexture: TSdlGpuTexture; out ASwapchainTextureWidth,
      ASwapchainTextureHeight: Integer); inline;

    /// <summary>
    ///  Submits the command buffer so its commands can be processed on the GPU.
    ///
    ///  It is invalid to use the command buffer after this is called.
    ///
    ///  This must be called from the thread the command buffer was acquired on.
    ///
    ///  All commands in the submission are guaranteed to begin executing before any
    ///  command in a subsequent submission begins executing.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuDevice.AcquireCommandBuffer"/>
    /// <seealso cref="WaitAndAcquireSwapchainTexture"/>
    /// <seealso cref="AcquireSwapchainTexture"/>
    /// <seealso cref="SubmitAndAcquireFence"/>
    procedure Submit; inline;

    /// <summary>
    ///  Submits the command buffer so its commands can be processed on the GPU, and
    ///  acquires a fence associated with the command buffer.
    ///
    ///  You must release this fence when it is no longer needed or it will cause a
    ///  leak. It is invalid to use the command buffer after this is called.
    ///
    ///  This must be called from the thread the command buffer was acquired on.
    ///
    ///  All commands in the submission are guaranteed to begin executing before any
    ///  command in a subsequent submission begins executing.
    /// </summary>
    /// <returns>A fence associated with the command buffer.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuDevice.AcquireCommandBuffer"/>
    /// <seealso cref="WaitAndAcquireSwapchainTexture"/>
    /// <seealso cref="AcquireSwapchainTexture"/>
    /// <seealso cref="Submit"/>
    /// <seealso cref="TSdlGpuDevice.ReleaseFence"/>
    function SubmitAndAcquireFence: TSdlGpuFence; inline;

    /// <summary>
    ///  Cancels the command buffer.
    ///
    ///  None of the enqueued commands are executed.
    ///
    ///  It is an error to call this method after a swapchain texture has been
    ///  acquired.
    ///
    ///  This must be called from the thread the command buffer was acquired on.
    ///
    ///  You must not reference the command buffer after calling this method.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="WaitAndAcquireSwapchainTexture"/>
    /// <seealso cref="TSdlGpuDevice.AcquireCommandBuffer"/>
    /// <seealso cref="AcquireSwapchainTexture"/>
    procedure Cancel; inline;
  end;

type
  /// <summary>
  ///  The SDL_GPU context.
  /// </summary>
  TSdlGpuDevice = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GPUDevice;
    function GetDriver: TSdlGpuDriver; inline;
    function GetFormats: TSdlGpuShaderFormats; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGpuDevice; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuDevice.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGpuDevice): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGpuDevice; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGpuDevice.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGpuDevice): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGpuDevice; inline; static;
  public
    /// <summary>
    ///  Creates a GPU context.
    /// </summary>
    /// <param name="AFormats">Which shader formats the app is able to provide.</param>
    /// <param name="ADebugMode">(Optional) True to enable debug mode properties
    ///  and validations. If not given, this will be True in when the app is
    ///  compiled in DEBUG mode, or False otherwise</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Formats"/>
    /// <seealso cref="Driver"/>
    /// <seealso cref="TSdlGpuDriver.SupportsFormats"/>
    constructor Create(const AFormats: TSdlGpuShaderFormats;
      const ADebugMode: Boolean = {$IFDEF DEBUG}True{$ELSE}False{$ENDIF}); overload;

    /// <summary>
    ///  Creates a GPU context.
    /// </summary>
    /// <param name="AFormats">Which shader formats the app is able to provide.</param>
    /// <param name="ADriver">The preferred GPU driver to use.</param>
    /// <param name="ADebugMode">(Optional) True to enable debug mode properties
    ///  and validations. If not given, this will be True in when the app is
    ///  compiled in DEBUG mode, or False otherwise</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Formats"/>
    /// <seealso cref="Driver"/>
    /// <seealso cref="TSdlGpuDriver.SupportsFormats"/>
    constructor Create(const AFormats: TSdlGpuShaderFormats;
      const ADriver: TSdlGpuDriver;
      const ADebugMode: Boolean = {$IFDEF DEBUG}True{$ELSE}False{$ENDIF}); overload;

    /// <summary>
    ///  Creates a GPU context.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlProperty.GpuDeviceCreateDebugMode`: enable debug mode
    ///    properties and validations, defaults to True.
    ///  - `TSdlProperty.GpuDeviceCreatePreferLowPower`: enable to prefer
    ///    energy efficiency over maximum GPU performance, defaults to False.
    ///  - `TSdlProperty.GpuDeviceCreateName`: the name of the GPU driver to
    ///    use, if a specific one is desired.
    ///
    ///  These are the current shader format properties:
    ///
    ///  - `TSdlProperty.GpuDeviceCreateShadersPrivate`: The app is able to
    ///    provide shaders for an NDA platform.
    ///  - `TSdlProperty.GpuDeviceCreateShadersSpirV`: The app is able to
    ///    provide SPIR-V shaders if applicable.
    ///  - `TSdlProperty.GpuDeviceCreateShadersDxbc`: The app is able to
    ///  provide DXBC shaders if applicable
    ///  - `TSdlProperty.GpuDeviceCreateShadersDxil`: The app is able to
    ///    provide DXIL shaders if applicable.
    ///  - `TSdlProperty.GpuDeviceCreateShadersMsl`: The app is able to
    ///    provide MSL shaders if applicable.
    ///  - `TSdlProperty.GpuDeviceCreateShadersMetalLib`: The app is able to
    ///    provide Metal shader libraries if applicable.
    ///
    ///  With the D3D12 renderer:
    ///
    ///  - `TSdlProperty.GpuDeviceCreateD3D12SemanticName`: the prefix to
    ///    use for all vertex semantics, default is 'TEXCOORD'.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <returns>a GPU context on success or NULL on failure; call SDL_GetError() for more information.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Formats"/>
    /// <seealso cref="Driver"/>
    /// <seealso cref="TSdlGpuDriver.SupportsProperties"/>
    constructor Create(const AProps: TSdlProperties); overload;

    /// <summary>
    ///  Destroys the GPU context.
    /// </summary>
    procedure Free; inline;

    /// <summary>
    ///  Creates a pipeline object to be used in a compute workflow.
    ///
    ///  Shader resource bindings must be authored to follow a particular order
    ///  depending on the shader format.
    ///
    ///  For SPIR-V shaders, use the following resource sets:
    ///
    ///  - 0: Sampled textures, followed by read-only storage textures, followed by
    ///       read-only storage buffers
    ///  - 1: Read-write storage textures, followed by read-write storage buffers
    ///  - 2: Uniform buffers
    ///
    ///  For DXBC and DXIL shaders, use the following register order:
    ///
    ///  - (t[n], space0): Sampled textures, followed by read-only storage textures,
    ///    followed by read-only storage buffers
    ///  - (u[n], space1): Read-write storage textures, followed by read-write
    ///    storage buffers
    ///  - (b[n], space2): Uniform buffers
    ///
    ///  For MSL/metallib, use the following order:
    ///
    ///  - [[buffer]]: Uniform buffers, followed by read-only storage buffers,
    ///    followed by read-write storage buffers
    ///  - [[texture]]: Sampled textures, followed by read-only storage textures,
    ///    followed by read-write storage textures
    ///
    ///  There are optional properties that can be provided through `Props`. These
    ///  are the supported properties:
    ///
    ///  - `TSdlProperty.GpuComputePipelineCreateName`: a name that can be
    ///    displayed in debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the compute
    ///  pipeline to create.</param>
    /// <returns>A compute pipeline object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuComputePass.BindStorageBuffers"/>
    /// <seealso cref="ReleaseComputePipeline"/>
    function CreateComputePipeline(
      const ACreateInfo: TSdlGpuComputePipelineCreateInfo): TSdlGpuComputePipeline; inline;

    /// <summary>
    ///  Frees the given compute pipeline as soon as it is safe to do so.
    ///
    ///  You must not reference the compute pipeline after calling this method.
    /// </summary>
    /// <param name="AComputePipeline">A compute pipeline to be destroyed.</param>
    procedure ReleaseComputePipeline(const AComputePipeline: TSdlGpuComputePipeline); inline;

    /// <summary>
    ///  Creates a pipeline object to be used in a graphics workflow.
    ///
    ///  There are optional properties that can be provided through `Props`. These
    ///  are the supported properties:
    ///
    ///  - `TSdlProperty.GpuGraphicsPipelineCreateName`: a name that can be
    ///    displayed in debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the graphics
    ///  pipeline to create.</param>
    /// <returns>A graphics pipeline object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuShader"/>
    /// <seealso cref="TSdlGpuRenderPass.BindPipeline"/>
    /// <seealso cref="ReleaseGraphicsPipeline"/>
    function CreateGraphicsPipeline(
      const ACreateInfo: TSdlGpuGraphicsPipelineCreateInfo): TSdlGpuGraphicsPipeline; inline;

    /// <summary>
    ///  Frees the given graphics pipeline as soon as it is safe to do so.
    ///
    ///  You must not reference the graphics pipeline after calling this method.
    /// </summary>
    /// <param name="AGraphicsPipeline">a graphics pipeline to be destroyed.</param>
    procedure ReleaseGraphicsPipeline(const AGraphicsPipeline: TSdlGpuGraphicsPipeline); inline;

    /// <summary>
    ///  Creates a sampler object to be used when binding textures in a graphics
    ///  workflow.
    ///
    ///  There are optional properties that can be provided through `Props`. These
    ///  are the supported properties:
    ///
    ///  - `TSdlProperty.GpuSamplerCreateName`: a name that can be displayed
    ///    in debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the sampler
    ///  to create.</param>
    /// <returns>A sampler object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuRenderPass.BindVertexSamplers"/>
    /// <seealso cref="TSdlGpuRenderPass.BindFragmentSamplers"/>
    /// <seealso cref="ReleaseSampler"/>
    function CreateSampler(
      const ACreateInfo: TSdlGpuSamplerCreateInfo): TSdlGpuSampler; inline;

    /// <summary>
    ///  Frees the given sampler as soon as it is safe to do so.
    ///
    ///  You must not reference the sampler after calling this method.
    /// </summary>
    /// <param name="ASampler">A sampler to be destroyed.</param>
    procedure ReleaseSampler(const ASampler: TSdlGpuSampler); inline;

    /// <summary>
    ///  Creates a shader to be used when creating a graphics pipeline.
    ///
    ///  Shader resource bindings must be authored to follow a particular order
    ///  depending on the shader format.
    ///
    ///  For SPIR-V shaders, use the following resource sets:
    ///
    ///  For vertex shaders:
    ///
    ///  - 0: Sampled textures, followed by storage textures, followed by storage
    ///    buffers
    ///  - 1: Uniform buffers
    ///
    ///  For fragment shaders:
    ///
    ///  - 2: Sampled textures, followed by storage textures, followed by storage
    ///    buffers
    ///  - 3: Uniform buffers
    ///
    ///  For DXBC and DXIL shaders, use the following register order:
    ///
    ///  For vertex shaders:
    ///
    ///  - (t[n], space0): Sampled textures, followed by storage textures, followed
    ///    by storage buffers
    ///  - (s[n], space0): Samplers with indices corresponding to the sampled
    ///    textures
    ///  - (b[n], space1): Uniform buffers
    ///
    ///  For pixel shaders:
    ///
    ///  - (t[n], space2): Sampled textures, followed by storage textures, followed
    ///    by storage buffers
    ///  - (s[n], space2): Samplers with indices corresponding to the sampled
    ///    textures
    ///  - (b[n], space3): Uniform buffers
    ///
    ///  For MSL/metallib, use the following order:
    ///
    ///  - [[texture]]: Sampled textures, followed by storage textures
    ///  - [[sampler]]: Samplers with indices corresponding to the sampled textures
    ///  - [[buffer]]: Uniform buffers, followed by storage buffers. Vertex buffer 0
    ///    is bound at [[buffer(14)]], vertex buffer 1 at [[buffer(15)]], and so on.
    ///    Rather than manually authoring vertex buffer indices, use the
    ///    [[stage_in]] attribute which will automatically use the vertex input
    ///    information from the SDL_GPUGraphicsPipeline.
    ///
    ///  Shader semantics other than system-value semantics do not matter in D3D12
    ///  and for ease of use the SDL implementation assumes that non system-value
    ///  semantics will all be TEXCOORD. If you are using HLSL as the shader source
    ///  language, your vertex semantics should start at TEXCOORD0 and increment
    ///  like so: TEXCOORD1, TEXCOORD2, etc. If you wish to change the semantic
    ///  prefix to something other than TEXCOORD you can use
    ///  TSdlProperty.GpuDeviceCreateD3D12SemanticName with TSdlGpuDevice.Create.
    ///
    ///  There are optional properties that can be provided through `Props`. These
    ///  are the supported properties:
    ///
    ///  - `TSdlProperty.GpuShaderCreateName`: a name that can be displayed in
    ///    debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the shader
    ///  to create.</param>
    /// <returns>A shader object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuGraphicsPipeline"/>
    /// <seealso cref="ReleaseShader"/>
    function CreateShader(
      const ACreateInfo: TSdlGpuShaderCreateInfo): TSdlGpuShader; inline;

    /// <summary>
    ///  Frees the given shader as soon as it is safe to do so.
    ///
    ///  You must not reference the shader after calling this method.
    /// </summary>
    /// <param name="AShader">A shader to be destroyed.</param>
    procedure ReleaseShader(const AShader: TSdlGpuShader); inline;

    /// <summary>
    ///  Creates a texture object to be used in graphics or compute workflows.
    ///
    ///  The contents of this texture are undefined until data is written to the
    ///  texture.
    ///
    ///  Note that certain combinations of usage flags are invalid. For example, a
    ///  texture cannot have both the Sampler and GraphicsStorageRead flags.
    ///
    ///  If you request a sample count higher than the hardware supports, the
    ///  implementation will automatically fall back to the highest available sample
    ///  count.
    ///
    ///  There are optional properties that can be provided through
    ///  TSdlGpuTextureCreateInfo's `Props`. These are the supported properties:
    ///
    ///  - `TSdlProperty.GpuTextureCreateD3D12ClearR`: (Direct3D 12 only) if
    ///    the texture usage is TSdlGpuTextureUsage.ColorTarget, clear the texture
    ///    to a color with this red intensity. Defaults to zero.
    ///  - `TSdlProperty.GpuTextureCreateD3D12ClearG`: (Direct3D 12 only) if
    ///    the texture usage is TSdlGpuTextureUsage.ColorTarget, clear the texture
    ///    to a color with this green intensity. Defaults to zero.
    ///  - `TSdlProperty.GpuTextureCreateD3D12ClearB`: (Direct3D 12 only) if
    ///    the texture usage is TSdlGpuTextureUsage.ColorTarget, clear the texture
    ///    to a color with this blue intensity. Defaults to zero.
    ///  - `TSdlProperty.GpuTextureCreateD3D12ClearA`: (Direct3D 12 only) if
    ///    the texture usage is TSdlGpuTextureUsage.ColorTarget, clear the texture
    ///    to a color with this alpha intensity. Defaults to zero.
    ///  - `TSdlProperty.GpuTextureCreateD3D12ClearDepth`: (Direct3D 12 only) if
    ///    the texture usage is TSdlGpuTextureUsage.DepthStencilTarget, clear
    ///    the texture to a depth of this value. Defaults to zero.
    ///  - `TSdlProperty.GpuTextureCreateD3D12ClearStencil`: (Direct3D 12 only) if
    ///    the texture usage is TSdlGpuTextureUsage.DepthStencilTarget, clear
    ///    the texture to a stencil of this value. Defaults to zero.
    ///  - `TSdlProperty.GpuTextureCreateName`: a name that can be displayed
    ///    in debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the texture
    ///  to create.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
    /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
    /// <seealso cref="TSdlGpuRenderPass.BindVertexSamplers"/>
    /// <seealso cref="TSdlGpuRenderPass.BindVertexStorageTextures"/>
    /// <seealso cref="TSdlGpuRenderPass.BindFragmentSamplers"/>
    /// <seealso cref="TSdlGpuRenderPass.BindFragmentStorageTextures"/>
    /// <seealso cref="TSdlGpuComputePass.BindStorageTextures"/>
    /// <seealso cref="TSdlGpuCommandBuffer.Blit"/>
    /// <seealso cref="ReleaseTexture"/>
    /// <seealso cref="TextureSupportsFormat"/>
    function CreateTexture(
      const ACreateInfo: TSdlGpuTextureCreateInfo): TSdlGpuTexture; inline;

    /// <summary>
    ///  Frees the given texture as soon as it is safe to do so.
    ///
    ///  You must not reference the texture after calling this method.
    /// </summary>
    /// <param name="ATexture">A texture to be destroyed.</param>
    procedure ReleaseTexture(const ATexture: TSdlGpuTexture); inline;

    /// <summary>
    ///  Sets an arbitrary string constant to label a texture.
    ///
    ///  You should use TSdlProperty.GpuTextureCreateName with CreateTexture
    ///  instead of this method to avoid thread safety issues.
    /// </summary>
    /// <param name="ATexture">A texture to attach the name to.</param>
    /// <param name="AName">A string constant to mark as the name of the texture.</param>
    /// <seealso cref="CreateTexture"/>
    /// <remarks>
    ///  This method is not thread safe, you must make sure the texture is not
    ///  simultaneously used by any other thread.
    /// </remarks>
    procedure SetTextureName(const ATexture: TSdlGpuTexture;
      const AName: String); inline;

    /// <summary>
    ///  Creates a buffer object to be used in graphics or compute workflows.
    ///
    ///  The contents of this buffer are undefined until data is written to the
    ///  buffer.
    ///
    ///  Note that certain combinations of usage flags are invalid. For example, a
    ///  buffer cannot have both the Vertex and Index flags.
    ///
    ///  If you use a Storage flag, the data in the buffer must respect std140
    ///  layout conventions. In practical terms this means you must ensure that
    ///  vec3 and vec4 fields are 16-byte aligned.
    ///
    ///  For better understanding of underlying concepts and memory management with
    ///  SDL GPU API, you may refer
    ///  [this blog post](https://moonside.games/posts/sdl-gpu-concepts-cycling/).
    ///
    ///  There are optional properties that can be provided through `Props`. These
    ///  are the supported properties:
    ///
    ///  - `TSdlProperty.GpuBufferCreateName`: a name that can be displayed in
    ///    debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the buffer
    ///  to create.</param>
    /// <returns>A buffer object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCopyPass.UploadToBuffer"/>
    /// <seealso cref="TSdlGpuCopyPass.DownloadFromBuffer"/>
    /// <seealso cref="TSdlGpuCopyPass.CopyBufferToBuffer"/>
    /// <seealso cref="TSdlGpuRenderPass.BindVertexBuffers"/>
    /// <seealso cref="TSdlGpuRenderPass.BindIndexBuffer"/>
    /// <seealso cref="TSdlGpuRenderPass.BindVertexStorageBuffers"/>
    /// <seealso cref="TSdlGpuRenderPass.BindFragmentStorageBuffers"/>
    /// <seealso cref="TSdlGpuRenderPass.DrawPrimitives"/>
    /// <seealso cref="TSdlGpuComputePass.BindStorageBuffers"/>
    /// <seealso cref="TSdlGpuComputePass.Dispatch"/>
    /// <seealso cref="ReleaseBuffer"/>
    function CreateBuffer(
      const ACreateInfo: TSdlGpuBufferCreateInfo): TSdlGpuBuffer; inline;

    /// <summary>
    ///  Frees the given buffer as soon as it is safe to do so.
    ///
    ///  You must not reference the buffer after calling this method.
    /// </summary>
    /// <param name="ABuffer">A buffer to be destroyed.</param>
    procedure ReleaseBuffer(const ABuffer: TSdlGpuBuffer); inline;

    /// <summary>
    ///  Sets an arbitrary string constant to label a buffer.
    ///
    ///  You should use TSdlProperty.GpuBufferCreateName with CreateBuffer
    ///  instead of this method to avoid thread safety issues.
    /// </summary>
    /// <param name="ABuffer">A buffer to attach the name to.</param>
    /// <param name="AName">A string constant to mark as the name of the buffer.</param>
    /// <seealso cref="CreateBuffer"/>
    /// <remarks>
    ///  This method is not thread safe, you must make sure the buffer is not
    ///  simultaneously used by any other thread.
    /// </remarks>
    procedure SetBufferName(const ABuffer: TSdlGpuBuffer;
      const AName: String); inline;

    /// <summary>
    ///  Creates a transfer buffer to be used when uploading to or downloading from
    ///  graphics resources.
    ///
    ///  Download buffers can be particularly expensive to create, so it is good
    ///  practice to reuse them if data will be downloaded regularly.
    ///
    ///  There are optional properties that can be provided through `Props`. These
    ///  are the supported properties:
    ///
    ///  - `TSdlProperty.GpuTransferBufferCreateName`: a name that can be
    ///    displayed in debugging tools.
    /// </summary>
    /// <param name="ACreateInfo">A record describing the state of the transfer
    ///  buffer to create.</param>
    /// <returns>A transfer buffer.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCopyPass.UploadToBuffer"/>
    /// <seealso cref="TSdlGpuCopyPass.DownloadFromBuffer"/>
    /// <seealso cref="TSdlGpuCopyPass.UploadToTexture"/>
    /// <seealso cref="TSdlGpuCopyPass.DownloadFromTexture"/>
    /// <seealso cref="ReleaseTransferBuffer"/>
    function CreateTransferBuffer(
      const ACreateInfo: TSdlGpuTransferBufferCreateInfo): TSdlGpuTransferBuffer; inline;

    /// <summary>
    ///  Frees the given transfer buffer as soon as it is safe to do so.
    ///
    ///  You must not reference the transfer buffer after calling this methpd.
    /// </summary>
    /// <param name="ATransferBuffer">a transfer buffer to be destroyed.</param>
    procedure ReleaseTransferBuffer(const ATransferBuffer: TSdlGpuTransferBuffer); inline;

    /// <summary>
    ///  Acquire a command buffer.
    ///
    ///  This command buffer is managed by the implementation and should not be
    ///  freed by the user. The command buffer may only be used on the thread it was
    ///  acquired on. The command buffer should be submitted on the thread it was
    ///  acquired on.
    ///
    ///  It is valid to acquire multiple command buffers on the same thread at once.
    ///  In fact a common design pattern is to acquire two command buffers per frame
    ///  where one is dedicated to render and compute passes and the other is
    ///  dedicated to copy passes and other preparatory work such as generating
    ///  mipmaps. Interleaving commands between the two command buffers reduces the
    ///  total amount of passes overall which improves rendering performance.
    /// </summary>
    /// <returns>A command buffer.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCommandBuffer.Submit"/>
    /// <seealso cref="TSdlGpuCommandBuffer.SubmitAndAcquireFence"/>
    function AcquireCommandBuffer: TSdlGpuCommandBuffer; inline;

    /// <summary>
    ///  Maps a transfer buffer into application address space.
    ///
    ///  You must unmap the transfer buffer before encoding upload commands.
    ///  The memory is owned by the graphics driver - do NOT call SdlFree on the
    ///  returned pointer.
    /// </summary>
    /// <param name="ATransferBuffer">A transfer buffer.</param>
    /// <param name="ACycle">If True, cycles the transfer buffer if it is
    ///  already bound.</param>
    /// <returns>The address of the mapped transfer buffer memory.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function MapTransferBuffer(const ATransferBuffer: TSdlGpuTransferBuffer;
      const ACycle: Boolean): Pointer; inline;

    /// <summary>
    ///  Unmaps a previously mapped transfer buffer.
    /// </summary>
    /// <param name="ATransferBuffer">A previously mapped transfer buffer.</param>
    procedure UnmapTransferBuffer(const ATransferBuffer: TSdlGpuTransferBuffer); inline;

    /// <summary>
    ///  Claims a window, creating a swapchain structure for it.
    ///
    ///  This must be called before TSdlGpuCommandBuffer.AcquireSwapchainTexture
    ///  is called using the window. You should only call this method from the
    ///  thread that created the window.
    ///
    ///  The swapchain will be created with TSdlGpuSwapchainComposition.Sdr and
    ///  TSdlGpuPresentMode.VSync. If you want to have different swapchain
    ///  parameters, you must call SetSwapchainParameters after claiming the
    ///  window.
    /// </summary>
    /// <param name="AWindow">A TSdlWindow.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture"/>
    /// <seealso cref="ReleaseWindow"/>
    /// <seealso cref="WindowSupportsPresentMode"/>
    /// <seealso cref="WindowSupportsSwapchainComposition"/>
    /// <remarks>
    ///  This method should only be called from the thread that created the window.
    /// </remarks>
    procedure ClaimWindow(const AWindow: TSdlWindow); inline;

    /// <summary>
    ///  Unclaims a window, destroying its swapchain structure.
    /// </summary>
    /// <param name="AWindow">A TSdlWindow that has been claimed.</param>
    /// <seealso cref="ClaimWindow"/>
    procedure ReleaseWindow(const AWindow: TSdlWindow); inline;

    /// <summary>
    ///  Determines whether a swapchain composition is supported by the window.
    ///
    ///  The window must be claimed before calling this method.
    /// </summary>
    /// <param name="AWindow">A TSdlWindow.</param>
    /// <param name="ASwapchainComposition">The swapchain composition to check.</param>
    /// <returns>True if supported, False if unsupported.</returns>
    /// <seealso cref="ClaimWindow"/>
    function WindowSupportsSwapchainComposition(const AWindow: TSdlWindow;
      const ASwapchainComposition: TSdlGpuSwapchainComposition): Boolean; inline;

    /// <summary>
    ///  Determines whether a presentation mode is supported by the window.
    ///
    ///  The window must be claimed before calling this function.
    /// </summary>
    /// <param name="AWindow">A TSdlWindow.</param>
    /// <param name="APresentMode">The presentation mode to check.</param>
    /// <returns>True if supported, False if unsupported.</returns>
    /// <seealso cref="ClaimWindow"/>
    function WindowSupportsPresentMode(const AWindow: TSdlWindow;
      const APresentMode: TSdlGpuPresentMode): Boolean; inline;

    /// <summary>
    ///  Changes the swapchain parameters for the given claimed window.
    ///
    ///  This method will fail if the requested present mode or swapchain
    ///  composition are unsupported by the device. Check if the parameters are
    ///  supported via WindowSupportsPresentMode /
    ///  WindowSupportsSwapchainComposition prior to calling this method.
    ///
    ///  TSdlGpuPresentMode.VSync and TSdlGpuSwapchainComposition.Sdr are always
    ///  supported.
    /// </summary>
    /// <param name="AWindow">A TSdlWindow that has been claimed.</param>
    /// <param name="ASwapchainComposition">The desired composition of the swapchain.</param>
    /// <param name="APresentMode">The desired present mode for the swapchain.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="WindowSupportsPresentMode"/>
    /// <seealso cref="WindowSupportsSwapchainComposition"/>
    procedure SetSwapchainParameters(const AWindow: TSdlWindow;
      const ASwapchainComposition: TSdlGpuSwapchainComposition;
      const APresentMode: TSdlGpuPresentMode); inline;

    /// <summary>
    ///  Configures the maximum allowed number of frames in flight.
    ///
    ///  The default value when the device is created is 2. This means that after
    ///  you have submitted 2 frames for presentation, if the GPU has not finished
    ///  working on the first frame, TSdlGpuCommandBuffer.AcquireSwapchainTexture
    ///  will fill the swapchain texture pointer with nil, and
    ///  TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture will block.
    ///
    ///  Higher values increase throughput at the expense of visual latency. Lower
    ///  values decrease visual latency at the expense of throughput.
    ///
    ///  Note that calling this function will stall and flush the command queue to
    ///  prevent synchronization issues.
    ///
    ///  The minimum value of allowed frames in flight is 1, and the maximum is 3.
    /// </summary>
    /// <param name="AAllowedFramesInFlight">The maximum number of frames that
    ///  can be pending on the GPU.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetAllowedFramesInFlight(const AAllowedFramesInFlight: Integer); inline;

    /// <summary>
    ///  Obtains the texture format of the swapchain for the given window.
    ///
    ///  Note that this format can change if the swapchain parameters change.
    /// </summary>
    /// <param name="AWindow">A TSdlWindow that has been claimed.</param>
    /// <returns>The texture format of the swapchain.</returns>
    function GetSwapchainTextureFormat(const AWindow: TSdlWindow): TSdlGpuTextureFormat; inline;

    /// <summary>
    ///  Blocks the thread until a swapchain texture is available to be acquired.
    /// </summary>
    /// <param name="AWindow">A window that has been claimed.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCommandBuffer.AcquireSwapchainTexture"/>
    /// <seealso cref="TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture"/>
    /// <seealso cref="SetAllowedFramesInFlight"/>
    /// <remarks>
    ///  This method should only be called from the thread that created the window.
    /// </remarks>
    procedure WaitForSwapchain(const AWindow: TSdlWindow); inline;

    /// <summary>
    ///  Blocks the thread until the GPU is completely idle.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="WaitForFences"/>
    procedure WaitForIdle; inline;

    /// <summary>
    ///  Blocks the thread until the given fences are signaled.
    /// </summary>
    /// <param name="AWaitAll">If False, wait for any fence to be signaled,
    ///  if True, wait for all fences to be signaled.</param>
    /// <param name="AFences">An array of fences to wait on.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuCommandBuffer.SubmitAndAcquireFence"/>
    /// <seealso cref="WaitForIdle"/>
    procedure WaitForFences(const AWaitAll: Boolean;
      const AFences: TArray<TSdlGpuFence>); inline;

    /// <summary>
    ///  Checks the status of a fence.
    /// </summary>
    /// <param name="AFence">A fence.</param>
    /// <returns>True if the fence is signaled, False if it is not.</returns>
    /// <seealso cref="TSdlGpuCommandBuffer.SubmitAndAcquireFence"/>
    function QueryFence(const AFence: TSdlGpuFence): Boolean; inline;

    /// <summary>
    ///  Releases a fence obtained from TSdlGpuCommandBuffer.SubmitAndAcquireFence.
    ///
    ///  You must not reference the fence after calling this method.
    /// </summary>
    /// <param name="AFence">A fence.</param>
    /// <seealso cref="TSdlGpuCommandBuffer.SubmitAndAcquireFence"/>
    procedure ReleaseFence(const AFence: TSdlGpuFence); inline;

    /// <summary>
    ///  Determines whether a texture format is supported for a given type and
    ///  usage.
    /// </summary>
    /// <param name="AFormat">The texture format to check.</param>
    /// <param name="AKind">The type of texture (2D, 3D, Cube).</param>
    /// <param name="AUsages">The usage scenarios to check.</param>
    /// <returns>Whether the texture format is supported for this type and usage.</returns>
    function TextureSupportsFormat(const AFormat: TSdlGpuTextureFormat;
      const AKind: TSdlGpuTextureKind; const AUsages: TSdlGpuTextureUsageFlags): Boolean; inline;

    /// <summary>
    ///  Determines if a sample count for a texture format is supported.
    /// </summary>
    /// <param name="AFormat">The texture format to check.</param>
    /// <param name="ASampleCount">The sample count to check.</param>
    /// <returns>A hardware-specific version of min(preferred, possible).</returns>
    function TextureSupportsSampleCount(const AFormat: TSdlGpuTextureFormat;
      const ASampleCount: TSdlGpuSampleCount): Boolean; inline;

    /// <summary>
    ///  The backend driver used to create this GPU context.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Driver: TSdlGpuDriver read GetDriver;

    /// <summary>
    ///  The supported shader formats for this GPU context.
    /// </summary>
    property Formats: TSdlGpuShaderFormats read GetFormats;
  end;

type
  _TSdlGpuDriverHelper = record helper for TSdlGpuDriver
  public
    /// <summary>
    ///  Creates a GPU context.
    /// </summary>
    /// <param name="AFormats">Which shader formats the app is able to provide.</param>
    /// <param name="ADebugMode">(Optional) True to enable debug mode properties
    ///  and validations. If not given, this will be True in when the app is
    ///  compiled in DEBUG mode, or False otherwise</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlGpuDevice.Formats"/>
    /// <seealso cref="TSdlGpuDevice.Driver"/>
    /// <seealso cref="TSdlGpuDriver.SupportsFormats"/>
    function CreateDevice(const AFormats: TSdlGpuShaderFormats;
      const ADebugMode: Boolean = {$IFDEF DEBUG}True{$ELSE}False{$ENDIF}): TSdlGpuDevice;
  end;
{$ENDREGION '3D Rendering and GPU Compute'}

implementation

{ _TSdlGpuTextureFormatHelper }

function _TSdlGpuTextureFormatHelper.CalculateSize(const AWidth, AHeight,
  ADepthOrLayerCount: Integer): Integer;
begin
  Result := SDL_CalculateGPUTextureFormatSize(Ord(Self), AWidth, AHeight, ADepthOrLayerCount);
end;

function _TSdlGpuTextureFormatHelper.GetTexelBlockSize: Integer;
begin
  Result := SDL_GPUTextureFormatTexelBlockSize(Ord(Self));
end;

{ TSdlGpuSamplerCreateInfo }

class function TSdlGpuSamplerCreateInfo.Create: TSdlGpuSamplerCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuSamplerCreateInfo.GetAddressModeU: TSdlGpuSamplerAddressMode;
begin
  Result := TSdlGpuSamplerAddressMode(FHandle.address_mode_u);
end;

function TSdlGpuSamplerCreateInfo.GetAddressModeV: TSdlGpuSamplerAddressMode;
begin
  Result := TSdlGpuSamplerAddressMode(FHandle.address_mode_v);
end;

function TSdlGpuSamplerCreateInfo.GetAddressModeW: TSdlGpuSamplerAddressMode;
begin
  Result := TSdlGpuSamplerAddressMode(FHandle.address_mode_w);
end;

function TSdlGpuSamplerCreateInfo.GetCompareOp: TSdlGpuCompareOp;
begin
  Result := TSdlGpuCompareOp(FHandle.compare_op);
end;

function TSdlGpuSamplerCreateInfo.GetMagFilter: TSdlGpuFilter;
begin
  Result := TSdlGpuFilter(FHandle.mag_filter);
end;

function TSdlGpuSamplerCreateInfo.GetMinFilter: TSdlGpuFilter;
begin
  Result := TSdlGpuFilter(FHandle.min_filter);
end;

function TSdlGpuSamplerCreateInfo.GetMipmapMode: TSdlGpuSamplerMipmapMode;
begin
  Result := TSdlGpuSamplerMipmapMode(FHandle.mipmap_mode);
end;

function TSdlGpuSamplerCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

procedure TSdlGpuSamplerCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuSamplerCreateInfo.SetAddressModeU(
  const AValue: TSdlGpuSamplerAddressMode);
begin
  FHandle.address_mode_u := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetAddressModeV(
  const AValue: TSdlGpuSamplerAddressMode);
begin
  FHandle.address_mode_v := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetAddressModeW(
  const AValue: TSdlGpuSamplerAddressMode);
begin
  FHandle.address_mode_w := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetCompareOp(const AValue: TSdlGpuCompareOp);
begin
  FHandle.compare_op := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetMagFilter(const AValue: TSdlGpuFilter);
begin
  FHandle.mag_filter := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetMinFilter(const AValue: TSdlGpuFilter);
begin
  FHandle.min_filter := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetMipmapMode(
  const AValue: TSdlGpuSamplerMipmapMode);
begin
  FHandle.mipmap_mode := Ord(AValue);
end;

procedure TSdlGpuSamplerCreateInfo.SetProps(const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue);
end;

{ TSdlGpuVertexBufferDescription }

function TSdlGpuVertexBufferDescription.GetInputRate: TSdlGpuVertexInputRate;
begin
  Result := TSdlGpuVertexInputRate(FHandle.input_rate);
end;

procedure TSdlGpuVertexBufferDescription.SetInputRate(
  const AValue: TSdlGpuVertexInputRate);
begin
  FHandle.input_rate := Ord(AValue);
end;

{ TSdlGpuVertexAttribute }

function TSdlGpuVertexAttribute.GetFormat: TSdlGpuVertexElementFormat;
begin
  Result := TSdlGpuVertexElementFormat(FHandle.format);
end;

procedure TSdlGpuVertexAttribute.SetFormat(
  const AValue: TSdlGpuVertexElementFormat);
begin
  FHandle.format := Ord(AValue);
end;

{ TSdlGpuVertexInputState }

procedure TSdlGpuVertexInputState.SetVertexAttributes(
  const AValue: TArray<TSdlGpuVertexAttribute>);
begin
  FVertexAttributes := AValue;
  FHandle.vertex_attributes := Pointer(AValue);
  FHandle.num_vertex_attributes := Length(AValue);
end;

procedure TSdlGpuVertexInputState.SetVertexBufferDescriptions(
  const AValue: TArray<TSdlGpuVertexBufferDescription>);
begin
  FVertexBufferDescriptions := AValue;
  FHandle.vertex_buffer_descriptions := Pointer(AValue);
  FHandle.num_vertex_buffers := Length(AValue);
end;

{ TSdlGpuColorTargetBlendState }

function TSdlGpuColorTargetBlendState.GetAlphaBlendOp: TSdlGpuBlendOp;
begin
  Result := TSdlGpuBlendOp(FHandle.alpha_blend_op);
end;

function TSdlGpuColorTargetBlendState.GetColorBlendOp: TSdlGpuBlendOp;
begin
  Result := TSdlGpuBlendOp(FHandle.color_blend_op);
end;

function TSdlGpuColorTargetBlendState.GetColorWriteMask: TSdlGpuColorComponentFlags;
begin
  Byte(Result) := FHandle.color_write_mask;
end;

function TSdlGpuColorTargetBlendState.GetDstAlphaBlendFctor: TSdlGpuBlendFactor;
begin
  Result := TSdlGpuBlendFactor(FHandle.dst_alpha_blendfactor);
end;

function TSdlGpuColorTargetBlendState.GetDstColorBlendFactor: TSdlGpuBlendFactor;
begin
  Result := TSdlGpuBlendFactor(FHandle.dst_color_blendfactor);
end;

function TSdlGpuColorTargetBlendState.GetSrcAlphaBlendFactor: TSdlGpuBlendFactor;
begin
  Result := TSdlGpuBlendFactor(FHandle.src_alpha_blendfactor);
end;

function TSdlGpuColorTargetBlendState.GetSrcColorBlendFactor: TSdlGpuBlendFactor;
begin
  Result := TSdlGpuBlendFactor(FHandle.src_color_blendfactor);
end;

procedure TSdlGpuColorTargetBlendState.SetAlphaBlendOp(
  const AValue: TSdlGpuBlendOp);
begin
  FHandle.alpha_blend_op := Ord(AValue);
end;

procedure TSdlGpuColorTargetBlendState.SetColorBlendOp(
  const AValue: TSdlGpuBlendOp);
begin
  FHandle.color_blend_op := Ord(AValue);
end;

procedure TSdlGpuColorTargetBlendState.SetColorWriteMask(
  const AValue: TSdlGpuColorComponentFlags);
begin
  FHandle.color_write_mask := Byte(AValue);
end;

procedure TSdlGpuColorTargetBlendState.SetDstAlphaBlendFctor(
  const AValue: TSdlGpuBlendFactor);
begin
  FHandle.dst_alpha_blendfactor := Ord(AValue);
end;

procedure TSdlGpuColorTargetBlendState.SetDstColorBlendFactor(
  const AValue: TSdlGpuBlendFactor);
begin
  FHandle.dst_color_blendfactor := Ord(AValue);
end;

procedure TSdlGpuColorTargetBlendState.SetSrcAlphaBlendFactor(
  const AValue: TSdlGpuBlendFactor);
begin
  FHandle.src_alpha_blendfactor := Ord(AValue);
end;

procedure TSdlGpuColorTargetBlendState.SetSrcColorBlendFactor(
  const AValue: TSdlGpuBlendFactor);
begin
  FHandle.src_color_blendfactor := Ord(AValue);
end;

{ TSdlGpuShaderCreateInfo }

class function TSdlGpuShaderCreateInfo.Create: TSdlGpuShaderCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuShaderCreateInfo.GetEntryPoint: String;
begin
  Result := String(FEntryPoint);
end;

function TSdlGpuShaderCreateInfo.GetFormat: TSdlGpuShaderFormat;
begin
  Result := TSdlGpuShaderFormat(FHandle.format);
end;

function TSdlGpuShaderCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

function TSdlGpuShaderCreateInfo.GetStage: TSdlGpuShaderStage;
begin
  Result := TSdlGpuShaderStage(FHandle.stage);
end;

procedure TSdlGpuShaderCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuShaderCreateInfo.SetCode(const AValue: TBytes);
begin
  FCode := AValue;
  FHandle.code_size := Length(AValue);
  FHandle.code := Pointer(AValue);
end;

procedure TSdlGpuShaderCreateInfo.SetEntryPoint(const AValue: String);
begin
  FEntryPoint := UTF8String(AValue);
  FHandle.entrypoint := PUTF8Char(FEntryPoint);
end;

procedure TSdlGpuShaderCreateInfo.SetFormat(const AValue: TSdlGpuShaderFormat);
begin
  FHandle.format := Ord(AValue);
end;

procedure TSdlGpuShaderCreateInfo.SetProps(const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue);
end;

procedure TSdlGpuShaderCreateInfo.SetStage(const AValue: TSdlGpuShaderStage);
begin
  FHandle.stage := Ord(AValue);
end;

{ TSdlGpuTextureCreateInfo }

class function TSdlGpuTextureCreateInfo.Create: TSdlGpuTextureCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuTextureCreateInfo.GetFormat: TSdlGpuTextureFormat;
begin
  Result := TSdlGpuTextureFormat(FHandle.format);
end;

function TSdlGpuTextureCreateInfo.GetKind: TSdlGpuTextureKind;
begin
  Result := TSdlGpuTextureKind(FHandle.&type);
end;

function TSdlGpuTextureCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

function TSdlGpuTextureCreateInfo.GetSampleCount: TSdlGpuSampleCount;
begin
  Result := TSdlGpuSampleCount(FHandle.sample_count);
end;

function TSdlGpuTextureCreateInfo.GetUsage: TSdlGpuTextureUsageFlags;
begin
  Byte(Result) := FHandle.usage;
end;

procedure TSdlGpuTextureCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuTextureCreateInfo.SetFormat(
  const AValue: TSdlGpuTextureFormat);
begin
  FHandle.format := Ord(AValue);
end;

procedure TSdlGpuTextureCreateInfo.SetKind(const AValue: TSdlGpuTextureKind);
begin
  FHandle.&type := Ord(AValue);
end;

procedure TSdlGpuTextureCreateInfo.SetProps(const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue);
end;

procedure TSdlGpuTextureCreateInfo.SetSampleCount(
  const AValue: TSdlGpuSampleCount);
begin
  FHandle.sample_count := Ord(AValue);
end;

procedure TSdlGpuTextureCreateInfo.SetUsage(
  const AValue: TSdlGpuTextureUsageFlags);
begin
  FHandle.usage := Byte(AValue);
end;

{ TSdlGpuBufferCreateInfo }

class function TSdlGpuBufferCreateInfo.Create: TSdlGpuBufferCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuBufferCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

function TSdlGpuBufferCreateInfo.GetUsage: TSdlGpuBufferUsageFlags;
begin
  Byte(Result) := FHandle.usage;
end;

procedure TSdlGpuBufferCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuBufferCreateInfo.SetProps(const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue);
end;

procedure TSdlGpuBufferCreateInfo.SetUsage(
  const AValue: TSdlGpuBufferUsageFlags);
begin
  FHandle.usage := Byte(AValue);
end;

{ TSdlGpuTransferBufferCreateInfo }

class function TSdlGpuTransferBufferCreateInfo.Create: TSdlGpuTransferBufferCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuTransferBufferCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

function TSdlGpuTransferBufferCreateInfo.GetUsage: TSdlGpuTransferBufferUsage;
begin
  Result := TSdlGpuTransferBufferUsage(FHandle.usage);
end;

procedure TSdlGpuTransferBufferCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuTransferBufferCreateInfo.SetProps(
  const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue);
end;

procedure TSdlGpuTransferBufferCreateInfo.SetUsage(
  const AValue: TSdlGpuTransferBufferUsage);
begin
  FHandle.usage := Ord(AValue);
end;

{ TSdlGpuRasterizerState }

function TSdlGpuRasterizerState.GetCullMode: TSdlGpuCullMode;
begin
  Result := TSdlGpuCullMode(FHandle.cull_mode);
end;

function TSdlGpuRasterizerState.GetFillMode: TSdlGpuFillMode;
begin
  Result := TSdlGpuFillMode(FHandle.fill_mode);
end;

function TSdlGpuRasterizerState.GetFrontFace: TSdlGpuFrontFace;
begin
  Result := TSdlGpuFrontFace(FHandle.front_face);
end;

procedure TSdlGpuRasterizerState.SetCullMode(const AValue: TSdlGpuCullMode);
begin
  FHandle.cull_mode := Ord(AValue);
end;

procedure TSdlGpuRasterizerState.SetFillMode(const AValue: TSdlGpuFillMode);
begin
  FHandle.fill_mode := Ord(AValue);
end;

procedure TSdlGpuRasterizerState.SetFrontFace(const AValue: TSdlGpuFrontFace);
begin
  FHandle.front_face := Ord(AValue);
end;

{ TSdlGpuMultisampleState }

function TSdlGpuMultisampleState.GetSampleCount: TSdlGpuSampleCount;
begin
  Result := TSdlGpuSampleCount(FHandle.sample_count);
end;

procedure TSdlGpuMultisampleState.SetSampleCount(
  const AValue: TSdlGpuSampleCount);
begin
  FHandle.sample_count := Ord(AValue);
end;

{ TSdlGpuDepthStencilState }

function TSdlGpuDepthStencilState.GetBackStencilState: PSdlGpuStencilOpState;
begin
  Result := @FHandle.back_stencil_state;
end;

function TSdlGpuDepthStencilState.GetCompareOp: TSdlGpuCompareOp;
begin
  Result := TSdlGpuCompareOp(FHandle.compare_op);
end;

function TSdlGpuDepthStencilState.GetFrontStencilState: PSdlGpuStencilOpState;
begin
  Result := @FHandle.front_stencil_state;
end;

procedure TSdlGpuDepthStencilState.SetCompareOp(const AValue: TSdlGpuCompareOp);
begin
  FHandle.compare_op := Ord(AValue);
end;

{ TSdlGpuColorTargetDescription }

function TSdlGpuColorTargetDescription.GetBlendState: PSdlGpuColorTargetBlendState;
begin
  Result := @FHandle.blend_state;
end;

function TSdlGpuColorTargetDescription.GetFormat: TSdlGpuTextureFormat;
begin
  Result := TSdlGpuTextureFormat(FHandle.format);
end;

procedure TSdlGpuColorTargetDescription.SetFormat(
  const AValue: TSdlGpuTextureFormat);
begin
  FHandle.format := Ord(AValue);
end;

{ TSdlGpuGraphicsPipelineTargetInfo }

function TSdlGpuGraphicsPipelineTargetInfo.GetDepthStencilFormat: TSdlGpuTextureFormat;
begin
  Result := TSdlGpuTextureFormat(FHandle.depth_stencil_format);
end;

procedure TSdlGpuGraphicsPipelineTargetInfo.SetColorTargetDescriptions(
  const AValue: TArray<TSdlGpuColorTargetDescription>);
begin
  FColorTargetDescriptions := AValue;
  FHandle.color_target_descriptions := Pointer(AValue);
  FHandle.num_color_targets := Length(AValue);
end;

procedure TSdlGpuGraphicsPipelineTargetInfo.SetDepthStencilFormat(
  const AValue: TSdlGpuTextureFormat);
begin
  FHandle.depth_stencil_format := Ord(AValue);
end;

{ TSdlGpuComputePipelineCreateInfo }

class function TSdlGpuComputePipelineCreateInfo.Create: TSdlGpuComputePipelineCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuComputePipelineCreateInfo.GetEntryPoint: String;
begin
  Result := String(FEntryPoint);
end;

function TSdlGpuComputePipelineCreateInfo.GetFormat: TSdlGpuShaderFormat;
begin
  Result := TSdlGpuShaderFormat(FHandle.format);
end;

function TSdlGpuComputePipelineCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

procedure TSdlGpuComputePipelineCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuComputePipelineCreateInfo.SetCode(const AValue: TBytes);
begin
  FCode := AValue;
  FHandle.code_size := Length(AValue);
  FHandle.code := Pointer(AValue);
end;

procedure TSdlGpuComputePipelineCreateInfo.SetEntryPoint(const AValue: String);
begin
  FEntryPoint := UTF8String(AValue);
  FHandle.entrypoint := PUTF8Char(FEntryPoint);
end;

procedure TSdlGpuComputePipelineCreateInfo.SetFormat(
  const AValue: TSdlGpuShaderFormat);
begin
  FHandle.format := Ord(AValue);
end;

procedure TSdlGpuComputePipelineCreateInfo.SetProps(
  const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue)
end;

{ TSdlGpuDriver }

class function TSdlGpuDriver.GetCount: Integer;
begin
  Result := SDL_GetNumGPUDrivers;
end;

class function TSdlGpuDriver.GetDefault: TSdlGpuDriver;
begin
  Result.FName := nil;
end;

class function TSdlGpuDriver.GetDriver(const AIndex: Integer): TSdlGpuDriver;
begin
  Result.FName := SDL_GetGPUDriver(AIndex);
end;

function TSdlGpuDriver.GetName: String;
begin
  Result := __ToString(FName);
end;

function TSdlGpuDriver.SupportsFormats(
  const AFormats: TSdlGpuShaderFormats): Boolean;
begin
  Result := SDL_GPUSupportsShaderFormats(Byte(AFormats), FName);
end;

class function TSdlGpuDriver.SupportsProperties(
  const AProps: TSdlProperties): Boolean;
begin
  Result := SDL_GPUSupportsProperties(SDL_PropertiesID(AProps));
end;

{ _TSdlGpuDriverHelper }

function _TSdlGpuDriverHelper.CreateDevice(const AFormats: TSdlGpuShaderFormats;
  const ADebugMode: Boolean): TSdlGpuDevice;
begin
  Result.FHandle := SDL_CreateGPUDevice(Byte(AFormats), ADebugMode, FName);
  SdlCheck(Result.FHandle);
end;

{ TSdlGpuComputePipeline }

class operator TSdlGpuComputePipeline.Equal(const ALeft: TSdlGpuComputePipeline;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuComputePipeline.Equal(const ALeft,
  ARight: TSdlGpuComputePipeline): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuComputePipeline.Implicit(const AValue: Pointer): TSdlGpuComputePipeline;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuComputePipeline.NotEqual(const ALeft,
  ARight: TSdlGpuComputePipeline): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuComputePipeline.NotEqual(
  const ALeft: TSdlGpuComputePipeline; const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuDevice }

constructor TSdlGpuDevice.Create(const AFormats: TSdlGpuShaderFormats;
  const ADebugMode: Boolean);
begin
  FHandle := SDL_CreateGPUDevice(Byte(AFormats), ADebugMode, nil);
  SdlCheck(FHandle);
end;

constructor TSdlGpuDevice.Create(const AFormats: TSdlGpuShaderFormats;
  const ADriver: TSdlGpuDriver; const ADebugMode: Boolean);
begin
  FHandle := SDL_CreateGPUDevice(Byte(AFormats), ADebugMode, ADriver.FName);
  SdlCheck(FHandle);
end;

function TSdlGpuDevice.AcquireCommandBuffer: TSdlGpuCommandBuffer;
begin
  Result.FHandle := SDL_AcquireGPUCommandBuffer(FHandle);
  SdlCheck(Result.FHandle);
end;

procedure TSdlGpuDevice.ClaimWindow(const AWindow: TSdlWindow);
begin
  SdlCheck(SDL_ClaimWindowForGPUDevice(FHandle, SDL_Window(AWindow)));
end;

constructor TSdlGpuDevice.Create(const AProps: TSdlProperties);
begin
  FHandle := SDL_CreateGPUDeviceWithProperties(SDL_PropertiesID(AProps));
  SdlCheck(FHandle);
end;

function TSdlGpuDevice.CreateBuffer(
  const ACreateInfo: TSdlGpuBufferCreateInfo): TSdlGpuBuffer;
begin
  Result.FHandle := SDL_CreateGPUBuffer(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGpuDevice.CreateComputePipeline(
  const ACreateInfo: TSdlGpuComputePipelineCreateInfo): TSdlGpuComputePipeline;
begin
  Result.FHandle := SDL_CreateGPUComputePipeline(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGpuDevice.CreateGraphicsPipeline(
  const ACreateInfo: TSdlGpuGraphicsPipelineCreateInfo): TSdlGpuGraphicsPipeline;
begin
  Result.FHandle :=  SDL_CreateGPUGraphicsPipeline(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGpuDevice.CreateSampler(
  const ACreateInfo: TSdlGpuSamplerCreateInfo): TSdlGpuSampler;
begin
  Result.FHandle := SDL_CreateGPUSampler(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGpuDevice.CreateShader(
  const ACreateInfo: TSdlGpuShaderCreateInfo): TSdlGpuShader;
begin
  Result.FHandle := SDL_CreateGPUShader(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGpuDevice.CreateTexture(
  const ACreateInfo: TSdlGpuTextureCreateInfo): TSdlGpuTexture;
begin
  Result.FHandle := SDL_CreateGPUTexture(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGpuDevice.CreateTransferBuffer(
  const ACreateInfo: TSdlGpuTransferBufferCreateInfo): TSdlGpuTransferBuffer;
begin
  Result.FHandle := SDL_CreateGPUTransferBuffer(FHandle, @ACreateInfo.FHandle);
  SdlCheck(Result.FHandle);
end;

class operator TSdlGpuDevice.Equal(const ALeft, ARight: TSdlGpuDevice): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuDevice.Equal(const ALeft: TSdlGpuDevice;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlGpuDevice.Free;
begin
  SDL_DestroyGPUDevice(FHandle);
  FHandle := 0;
end;

function TSdlGpuDevice.GetDriver: TSdlGpuDriver;
begin
  Result.FName := SDL_GetGPUDeviceDriver(FHandle);
  SdlCheck(Result.FName);
end;

function TSdlGpuDevice.GetFormats: TSdlGpuShaderFormats;
begin
  Byte(Result) := SDL_GetGPUShaderFormats(FHandle);
end;

function TSdlGpuDevice.GetSwapchainTextureFormat(
  const AWindow: TSdlWindow): TSdlGpuTextureFormat;
begin
  Result := TSdlGpuTextureFormat(SDL_GetGPUSwapchainTextureFormat(FHandle,
    SDL_Window(AWindow)));
end;

class operator TSdlGpuDevice.Implicit(const AValue: Pointer): TSdlGpuDevice;
begin
  Result.FHandle := THandle(AValue);
end;

function TSdlGpuDevice.MapTransferBuffer(
  const ATransferBuffer: TSdlGpuTransferBuffer; const ACycle: Boolean): Pointer;
begin
  Result := SDL_MapGPUTransferBuffer(FHandle, ATransferBuffer.FHandle, ACycle);
  SdlCheck(Result);
end;

class operator TSdlGpuDevice.NotEqual(const ALeft,
  ARight: TSdlGpuDevice): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuDevice.NotEqual(const ALeft: TSdlGpuDevice;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

function TSdlGpuDevice.QueryFence(const AFence: TSdlGpuFence): Boolean;
begin
  Result := SDL_QueryGPUFence(FHandle, AFence.FHandle);
end;

procedure TSdlGpuDevice.ReleaseBuffer(const ABuffer: TSdlGpuBuffer);
begin
  SDL_ReleaseGPUBuffer(FHandle, ABuffer.FHandle);
end;

procedure TSdlGpuDevice.ReleaseComputePipeline(
  const AComputePipeline: TSdlGpuComputePipeline);
begin
  SDL_ReleaseGPUComputePipeline(FHandle, AComputePipeline.FHandle);
end;

procedure TSdlGpuDevice.ReleaseFence(const AFence: TSdlGpuFence);
begin
  SDL_ReleaseGPUFence(FHandle, AFence.FHandle);
end;

procedure TSdlGpuDevice.ReleaseGraphicsPipeline(
  const AGraphicsPipeline: TSdlGpuGraphicsPipeline);
begin
  SDL_ReleaseGPUGraphicsPipeline(FHandle, AGraphicsPipeline.FHandle);
end;

procedure TSdlGpuDevice.ReleaseSampler(const ASampler: TSdlGpuSampler);
begin
  SDL_ReleaseGPUSampler(FHandle, ASampler.FHandle);
end;

procedure TSdlGpuDevice.ReleaseShader(const AShader: TSdlGpuShader);
begin
  SDL_ReleaseGPUShader(FHandle, AShader.FHandle);
end;

procedure TSdlGpuDevice.ReleaseTexture(const ATexture: TSdlGpuTexture);
begin
  SDL_ReleaseGPUTexture(FHandle, ATexture.FHandle);
end;

procedure TSdlGpuDevice.ReleaseTransferBuffer(
  const ATransferBuffer: TSdlGpuTransferBuffer);
begin
  SDL_ReleaseGPUTransferBuffer(FHandle, ATransferBuffer.FHandle);
end;

procedure TSdlGpuDevice.ReleaseWindow(const AWindow: TSdlWindow);
begin
  SDL_ReleaseWindowFromGPUDevice(FHandle, SDL_Window(AWindow));
end;

procedure TSdlGpuDevice.SetAllowedFramesInFlight(
  const AAllowedFramesInFlight: Integer);
begin
  SdlCheck(SDL_SetGPUAllowedFramesInFlight(FHandle, AAllowedFramesInFlight));
end;

procedure TSdlGpuDevice.SetBufferName(const ABuffer: TSdlGpuBuffer;
  const AName: String);
begin
  SDL_SetGPUBufferName(FHandle, ABuffer.FHandle, __ToUtf8(AName));
end;

procedure TSdlGpuDevice.SetSwapchainParameters(const AWindow: TSdlWindow;
  const ASwapchainComposition: TSdlGpuSwapchainComposition;
  const APresentMode: TSdlGpuPresentMode);
begin
  SdlCheck(SDL_SetGPUSwapchainParameters(FHandle, SDL_Window(AWindow),
    Ord(ASwapchainComposition), Ord(APresentMode)));
end;

procedure TSdlGpuDevice.SetTextureName(const ATexture: TSdlGpuTexture;
  const AName: String);
begin
  SDL_SetGPUTextureName(FHandle, ATexture.FHandle, __ToUtf8(AName));
end;

function TSdlGpuDevice.TextureSupportsFormat(
  const AFormat: TSdlGpuTextureFormat; const AKind: TSdlGpuTextureKind;
  const AUsages: TSdlGpuTextureUsageFlags): Boolean;
begin
  Result := SDL_GPUTextureSupportsFormat(FHandle, Ord(AFormat), Ord(AKind),
    Byte(AUsages));
end;

function TSdlGpuDevice.TextureSupportsSampleCount(
  const AFormat: TSdlGpuTextureFormat;
  const ASampleCount: TSdlGpuSampleCount): Boolean;
begin
  Result := SDL_GPUTextureSupportsSampleCount(FHandle, Ord(AFormat), Ord(ASampleCount));
end;

procedure TSdlGpuDevice.UnmapTransferBuffer(
  const ATransferBuffer: TSdlGpuTransferBuffer);
begin
  SDL_UnmapGPUTransferBuffer(FHandle, ATransferBuffer.FHandle);
end;

procedure TSdlGpuDevice.WaitForFences(const AWaitAll: Boolean;
  const AFences: TArray<TSdlGpuFence>);
begin
  SdlCheck(SDL_WaitForGPUFences(FHandle, AWaitAll, Pointer(AFences), Length(AFences)));
end;

procedure TSdlGpuDevice.WaitForIdle;
begin
  SdlCheck(SDL_WaitForGPUIdle(FHandle));
end;

procedure TSdlGpuDevice.WaitForSwapchain(const AWindow: TSdlWindow);
begin
  SdlCheck(SDL_WaitForGPUSwapchain(FHandle, SDL_Window(AWindow)));
end;

function TSdlGpuDevice.WindowSupportsPresentMode(const AWindow: TSdlWindow;
  const APresentMode: TSdlGpuPresentMode): Boolean;
begin
  Result := SDL_WindowSupportsGPUPresentMode(FHandle, SDL_Window(AWindow),
    Ord(APresentMode));
end;

function TSdlGpuDevice.WindowSupportsSwapchainComposition(
  const AWindow: TSdlWindow;
  const ASwapchainComposition: TSdlGpuSwapchainComposition): Boolean;
begin
  Result := SDL_WindowSupportsGPUSwapchainComposition(FHandle,
    SDL_Window(AWindow), Ord(ASwapchainComposition));
end;

{ TSdlGpuBuffer }

class operator TSdlGpuBuffer.Equal(const ALeft: TSdlGpuBuffer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuBuffer.Equal(const ALeft, ARight: TSdlGpuBuffer): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuBuffer.Implicit(const AValue: Pointer): TSdlGpuBuffer;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuBuffer.NotEqual(const ALeft,
  ARight: TSdlGpuBuffer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuBuffer.NotEqual(const ALeft: TSdlGpuBuffer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuBufferLocation }

function TSdlGpuBufferLocation.GetBuffer: TSdlGpuBuffer;
begin
  Result.FHandle := FHandle.buffer;
end;

procedure TSdlGpuBufferLocation.SetBuffer(const AValue: TSdlGpuBuffer);
begin
  FHandle.buffer := AValue.FHandle;
end;

{ TSdlGpuBufferRegion }

function TSdlGpuBufferRegion.GetBuffer: TSdlGpuBuffer;
begin
  Result.FHandle := FHandle.buffer;
end;

procedure TSdlGpuBufferRegion.SetBuffer(const AValue: TSdlGpuBuffer);
begin
  FHandle.buffer := AValue.FHandle;
end;

{ TSdlGpuBufferBinding }

function TSdlGpuBufferBinding.GetBuffer: TSdlGpuBuffer;
begin
  Result.FHandle := FHandle.buffer;
end;

procedure TSdlGpuBufferBinding.SetBuffer(const AValue: TSdlGpuBuffer);
begin
  FHandle.buffer := AValue.FHandle;
end;

{ TSdlGpuStorageBufferReadWriteBinding }

function TSdlGpuStorageBufferReadWriteBinding.GetBuffer: TSdlGpuBuffer;
begin
  Result.FHandle := FHandle.buffer;
end;

procedure TSdlGpuStorageBufferReadWriteBinding.SetBuffer(
  const AValue: TSdlGpuBuffer);
begin
  FHandle.buffer := AValue.FHandle;
end;

{ TSdlGpuTransferBuffer }

class operator TSdlGpuTransferBuffer.Equal(const ALeft: TSdlGpuTransferBuffer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuTransferBuffer.Equal(const ALeft,
  ARight: TSdlGpuTransferBuffer): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuTransferBuffer.Implicit(const AValue: Pointer): TSdlGpuTransferBuffer;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuTransferBuffer.NotEqual(const ALeft,
  ARight: TSdlGpuTransferBuffer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuTransferBuffer.NotEqual(
  const ALeft: TSdlGpuTransferBuffer; const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuTextureTransferInfo }

function TSdlGpuTextureTransferInfo.GetTransferBuffer: TSdlGpuTransferBuffer;
begin
  Result.FHandle := FHandle.transfer_buffer;
end;

procedure TSdlGpuTextureTransferInfo.SetTransferBuffer(
  const AValue: TSdlGpuTransferBuffer);
begin
  FHandle.transfer_buffer := AValue.FHandle;
end;

{ TSdlGpuTransferBufferLocation }

function TSdlGpuTransferBufferLocation.GetTransferBuffer: TSdlGpuTransferBuffer;
begin
  Result.FHandle := FHandle.transfer_buffer;
end;

procedure TSdlGpuTransferBufferLocation.SetTransferBuffer(
  const AValue: TSdlGpuTransferBuffer);
begin
  FHandle.transfer_buffer := AValue.FHandle;
end;

{ TSdlGpuTexture }

class operator TSdlGpuTexture.Equal(const ALeft: TSdlGpuTexture;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuTexture.Equal(const ALeft,
  ARight: TSdlGpuTexture): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuTexture.Implicit(const AValue: Pointer): TSdlGpuTexture;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuTexture.NotEqual(const ALeft,
  ARight: TSdlGpuTexture): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuTexture.NotEqual(const ALeft: TSdlGpuTexture;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuTextureLocation }

function TSdlGpuTextureLocation.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuTextureLocation.SetTexture(const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuTextureRegion }

function TSdlGpuTextureRegion.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuTextureRegion.SetTexture(const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuBlitRegion }

function TSdlGpuBlitRegion.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuBlitRegion.SetTexture(const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuBlitInfo }

function TSdlGpuBlitInfo.GetClearColor: TSdlColorF;
begin
  Result := TSdlColorF(FHandle.clear_color);
end;

function TSdlGpuBlitInfo.GetDestination: PSdlGpuBlitRegion;
begin
  Result := @FHandle.destination;
end;

function TSdlGpuBlitInfo.GetFilter: TSdlGpuFilter;
begin
  Result := TSdlGpuFilter(FHandle.filter);
end;

function TSdlGpuBlitInfo.GetFlipMode: TSdlFlipMode;
begin
  Result := TSdlFlipMode(FHandle.flip_mode);
end;

function TSdlGpuBlitInfo.GetLoadOp: TSdlGpuLoadOp;
begin
  Result := TSdlGpuLoadOp(FHandle.load_op);
end;

function TSdlGpuBlitInfo.GetSource: PSdlGpuBlitRegion;
begin
  Result := @FHandle.source;
end;

procedure TSdlGpuBlitInfo.SetClearColor(const AValue: TSdlColorF);
begin
  FHandle.clear_color := SDL_FColor(AValue);
end;

procedure TSdlGpuBlitInfo.SetFilter(const AValue: TSdlGpuFilter);
begin
  FHandle.filter := Ord(AValue);
end;

procedure TSdlGpuBlitInfo.SetFlipMode(const AValue: TSdlFlipMode);
begin
  FHandle.flip_mode := Ord(AValue);
end;

procedure TSdlGpuBlitInfo.SetLoadOp(const AValue: TSdlGpuLoadOp);
begin
  FHandle.load_op := Ord(AValue);
end;

{ TSdlGpuColorTargetInfo }

function TSdlGpuColorTargetInfo.GetClearColor: TSdlColorF;
begin
  Result := TSdlColorF(FHandle.clear_color);
end;

function TSdlGpuColorTargetInfo.GetLoadOp: TSdlGpuLoadOp;
begin
  Result := TSdlGpuLoadOp(FHandle.load_op);
end;

function TSdlGpuColorTargetInfo.GetResolveTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.resolve_texture;
end;

function TSdlGpuColorTargetInfo.GetStoreOp: TSdlGpuStoreOp;
begin
  Result := TSdlGpuStoreOp(FHandle.store_op);
end;

function TSdlGpuColorTargetInfo.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuColorTargetInfo.SetClearColor(const AValue: TSdlColorF);
begin
  FHandle.clear_color := SDL_FColor(AValue);
end;

procedure TSdlGpuColorTargetInfo.SetLoadOp(const AValue: TSdlGpuLoadOp);
begin
  FHandle.load_op := Ord(AValue);
end;

procedure TSdlGpuColorTargetInfo.SetResolveTexture(
  const AValue: TSdlGpuTexture);
begin
  FHandle.resolve_texture := AValue.FHandle;
end;

procedure TSdlGpuColorTargetInfo.SetStoreOp(const AValue: TSdlGpuStoreOp);
begin
  FHandle.store_op := Ord(AValue);
end;

procedure TSdlGpuColorTargetInfo.SetTexture(const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuDepthStencilTargetInfo }

function TSdlGpuDepthStencilTargetInfo.GetLoadOp: TSdlGpuLoadOp;
begin
  Result := TSdlGpuLoadOp(FHandle.load_op);
end;

function TSdlGpuDepthStencilTargetInfo.GetStencilLoadOp: TSdlGpuLoadOp;
begin
  Result := TSdlGpuLoadOp(FHandle.stencil_load_op);
end;

function TSdlGpuDepthStencilTargetInfo.GetStencilStoreOp: TSdlGpuStoreOp;
begin
  Result := TSdlGpuStoreOp(FHandle.stencil_store_op);
end;

function TSdlGpuDepthStencilTargetInfo.GetStoreOp: TSdlGpuStoreOp;
begin
  Result := TSdlGpuStoreOp(FHandle.store_op);
end;

function TSdlGpuDepthStencilTargetInfo.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuDepthStencilTargetInfo.SetLoadOp(const AValue: TSdlGpuLoadOp);
begin
  FHandle.load_op := Ord(AValue);
end;

procedure TSdlGpuDepthStencilTargetInfo.SetStencilLoadOp(
  const AValue: TSdlGpuLoadOp);
begin
  FHandle.stencil_load_op := Ord(AValue);
end;

procedure TSdlGpuDepthStencilTargetInfo.SetStencilStoreOp(
  const AValue: TSdlGpuStoreOp);
begin
  FHandle.stencil_store_op := Ord(AValue);
end;

procedure TSdlGpuDepthStencilTargetInfo.SetStoreOp(
  const AValue: TSdlGpuStoreOp);
begin
  FHandle.store_op := Ord(AValue);
end;

procedure TSdlGpuDepthStencilTargetInfo.SetTexture(
  const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuStorageTextureReadWriteBinding }

function TSdlGpuStorageTextureReadWriteBinding.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuStorageTextureReadWriteBinding.SetTexture(
  const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuSampler }

class operator TSdlGpuSampler.Equal(const ALeft: TSdlGpuSampler;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuSampler.Equal(const ALeft,
  ARight: TSdlGpuSampler): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuSampler.Implicit(const AValue: Pointer): TSdlGpuSampler;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuSampler.NotEqual(const ALeft,
  ARight: TSdlGpuSampler): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuSampler.NotEqual(const ALeft: TSdlGpuSampler;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuTextureSamplerBinding }

function TSdlGpuTextureSamplerBinding.GetSampler: TSdlGpuSampler;
begin
  Result.FHandle := FHandle.sampler;
end;

function TSdlGpuTextureSamplerBinding.GetTexture: TSdlGpuTexture;
begin
  Result.FHandle := FHandle.texture;
end;

procedure TSdlGpuTextureSamplerBinding.SetSampler(const AValue: TSdlGpuSampler);
begin
  FHandle.sampler := AValue.FHandle;
end;

procedure TSdlGpuTextureSamplerBinding.SetTexture(const AValue: TSdlGpuTexture);
begin
  FHandle.texture := AValue.FHandle;
end;

{ TSdlGpuShader }

class operator TSdlGpuShader.Equal(const ALeft: TSdlGpuShader;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuShader.Equal(const ALeft, ARight: TSdlGpuShader): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuShader.Implicit(const AValue: Pointer): TSdlGpuShader;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuShader.NotEqual(const ALeft,
  ARight: TSdlGpuShader): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuShader.NotEqual(const ALeft: TSdlGpuShader;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuGraphicsPipelineCreateInfo }

class function TSdlGpuGraphicsPipelineCreateInfo.Create: TSdlGpuGraphicsPipelineCreateInfo;
begin
  Result.Init;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetDepthStencilState: PSdlGpuDepthStencilState;
begin
  Result := @FHandle.depth_stencil_state;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetFragmentShader: TSdlGpuShader;
begin
  Result.FHandle := FHandle.fragment_shader;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetMultisampleState: PSdlGpuMultisampleState;
begin
  Result := @FHandle.multisample_state;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetPrimitiveType: TSdlGpuPrimitiveType;
begin
  Result := TSdlGpuPrimitiveType(FHandle.primitive_type);
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetProps: TSdlProperties;
begin
  SDL_PropertiesID(Result) := FHandle.props;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetRasterizerState: PSdlGpuRasterizerState;
begin
  Result := @FHandle.rasterizer_state;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetTargetInfo: TSdlGpuGraphicsPipelineTargetInfo;
begin
  Result.FHandle := FHandle.target_info;
  Result.FColorTargetDescriptions := FColorTargetDescriptions;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetVertexInputState: TSdlGpuVertexInputState;
begin
  Result.FHandle := FHandle.vertex_input_state;
  Result.FVertexBufferDescriptions := FVertexBufferDescriptions;
  Result.FVertexAttributes := FVertexAttributes;
end;

function TSdlGpuGraphicsPipelineCreateInfo.GetVertexShader: TSdlGpuShader;
begin
  Result.FHandle := FHandle.vertex_shader;
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.SetFragmentShader(
  const AValue: TSdlGpuShader);
begin
  FHandle.fragment_shader := AValue.FHandle;
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.SetPrimitiveType(
  const AValue: TSdlGpuPrimitiveType);
begin
  FHandle.primitive_type := Ord(AValue);
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.SetProps(
  const AValue: TSdlProperties);
begin
  FHandle.props := SDL_PropertiesID(AValue);
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.SetTargetInfo(
  const AValue: TSdlGpuGraphicsPipelineTargetInfo);
begin
  FHandle.target_info := AValue.FHandle;
  FColorTargetDescriptions := AValue.FColorTargetDescriptions;
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.SetVertexInputState(
  const AValue: TSdlGpuVertexInputState);
begin
  FHandle.vertex_input_state := AValue.FHandle;
  FVertexBufferDescriptions := AValue.FVertexBufferDescriptions;
  FVertexAttributes := AValue.FVertexAttributes;
end;

procedure TSdlGpuGraphicsPipelineCreateInfo.SetVertexShader(
  const AValue: TSdlGpuShader);
begin
  FHandle.vertex_shader := AValue.FHandle;
end;

{ TSdlGpuGraphicsPipeline }

class operator TSdlGpuGraphicsPipeline.Equal(
  const ALeft: TSdlGpuGraphicsPipeline; const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuGraphicsPipeline.Equal(const ALeft,
  ARight: TSdlGpuGraphicsPipeline): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuGraphicsPipeline.Implicit(
  const AValue: Pointer): TSdlGpuGraphicsPipeline;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuGraphicsPipeline.NotEqual(const ALeft,
  ARight: TSdlGpuGraphicsPipeline): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuGraphicsPipeline.NotEqual(
  const ALeft: TSdlGpuGraphicsPipeline; const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuCommandBuffer }

procedure TSdlGpuCommandBuffer.AcquireSwapchainTexture(
  const AWindow: TSdlWindow; out ASwapchainTexture: TSdlGpuTexture;
  out ASwapchainTextureWidth, ASwapchainTextureHeight: Integer);
begin
  SdlCheck(SDL_AcquireGPUSwapchainTexture(FHandle, SDL_Window(AWindow),
    @ASwapchainTexture.FHandle, @ASwapchainTextureWidth, @ASwapchainTextureHeight));
end;

function TSdlGpuCommandBuffer.BeginComputePass(
  const AStorageTextureBindings: TArray<TSdlGpuStorageTextureReadWriteBinding>;
  const AStorageBufferBindings: TArray<TSdlGpuStorageBufferReadWriteBinding>): TSdlGpuComputePass;
begin
  Result.FHandle := SDL_BeginGPUComputePass(FHandle,
    Pointer(AStorageTextureBindings), Length(AStorageTextureBindings),
    Pointer(AStorageBufferBindings), Length(AStorageBufferBindings));
end;

function TSdlGpuCommandBuffer.BeginCopyPass: TSdlGpuCopyPass;
begin
  Result.FHandle := SDL_BeginGPUCopyPass(FHandle);
end;

function TSdlGpuCommandBuffer.BeginRenderPass(
  const AColorTargetInfos: TArray<TSdlGpuColorTargetInfo>;
  const ADepthStencilTargetInfo: TSdlGpuDepthStencilTargetInfo): TSdlGpuRenderPass;
begin
  Result.FHandle := SDL_BeginGPURenderPass(FHandle, Pointer(AColorTargetInfos),
    Length(AColorTargetInfos), @ADepthStencilTargetInfo.FHandle);
end;

procedure TSdlGpuCommandBuffer.Blit(const AInfo: TSdlGpuBlitInfo);
begin
  SDL_BlitGPUTexture(FHandle, @AInfo.FHandle);
end;

procedure TSdlGpuCommandBuffer.Cancel;
begin
  SdlCheck(SDL_CancelGPUCommandBuffer(FHandle));
  FHandle := 0;
end;

class operator TSdlGpuCommandBuffer.Equal(const ALeft,
  ARight: TSdlGpuCommandBuffer): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlGpuCommandBuffer.BeginRenderPass(
  const AColorTargetInfos: TArray<TSdlGpuColorTargetInfo>): TSdlGpuRenderPass;
begin
  Result.FHandle := SDL_BeginGPURenderPass(FHandle, Pointer(AColorTargetInfos),
    Length(AColorTargetInfos), nil);
end;

class operator TSdlGpuCommandBuffer.Equal(const ALeft: TSdlGpuCommandBuffer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlGpuCommandBuffer.GenerateMipmaps(const ATexture: TSdlGpuTexture);
begin
  SDL_GenerateMipmapsForGPUTexture(FHandle, ATexture.FHandle);
end;

class operator TSdlGpuCommandBuffer.Implicit(const AValue: Pointer): TSdlGpuCommandBuffer;
begin
  Result.FHandle := THandle(AValue);
end;

procedure TSdlGpuCommandBuffer.InsertDebugLabel(const AText: String);
begin
  SDL_InsertGPUDebugLabel(FHandle, __ToUtf8(AText));
end;

class operator TSdlGpuCommandBuffer.NotEqual(const ALeft,
  ARight: TSdlGpuCommandBuffer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuCommandBuffer.NotEqual(const ALeft: TSdlGpuCommandBuffer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlGpuCommandBuffer.PopDebugGroup;
begin
  SDL_PopGPUDebugGroup(FHandle);
end;

procedure TSdlGpuCommandBuffer.PushComputeUniformData(const ASlotIndex: Integer;
  const AData: Pointer; const ASize: Integer);
begin
  SDL_PushGPUComputeUniformData(FHandle, ASlotIndex, AData, ASize);
end;

procedure TSdlGpuCommandBuffer.PushComputeUniformData(const ASlotIndex: Integer;
  const AData: TBytes);
begin
  SDL_PushGPUComputeUniformData(FHandle, ASlotIndex, AData, Length(AData));
end;

procedure TSdlGpuCommandBuffer.PushDebugGroup(const AName: String);
begin
  SDL_PushGPUDebugGroup(FHandle, __ToUtf8(AName));
end;

procedure TSdlGpuCommandBuffer.PushFragmentUniformData(
  const ASlotIndex: Integer; const AData: Pointer; const ASize: Integer);
begin
  SDL_PushGPUFragmentUniformData(FHandle, ASlotIndex, AData, ASize);
end;

procedure TSdlGpuCommandBuffer.PushFragmentUniformData(
  const ASlotIndex: Integer; const AData: TBytes);
begin
  SDL_PushGPUFragmentUniformData(FHandle, ASlotIndex, AData, Length(AData));
end;

procedure TSdlGpuCommandBuffer.PushVertexUniformData(const ASlotIndex: Integer;
  const AData: Pointer; const ASize: Integer);
begin
  SDL_PushGPUVertexUniformData(FHandle, ASlotIndex, AData, ASize);
end;

procedure TSdlGpuCommandBuffer.Submit;
begin
  SdlCheck(SDL_SubmitGPUCommandBuffer(FHandle));
  FHandle := 0;
end;

function TSdlGpuCommandBuffer.SubmitAndAcquireFence: TSdlGpuFence;
begin
  Result.FHandle := SDL_SubmitGPUCommandBufferAndAcquireFence(FHandle);
  SdlCheck(Result.FHandle);
end;

procedure TSdlGpuCommandBuffer.WaitAndAcquireSwapchainTexture(
  const AWindow: TSdlWindow; out ASwapchainTexture: TSdlGpuTexture;
  out ASwapchainTextureWidth, ASwapchainTextureHeight: Integer);
begin
  SdlCheck(SDL_WaitAndAcquireGPUSwapchainTexture(FHandle, SDL_Window(AWindow),
    @ASwapchainTexture.FHandle, @ASwapchainTextureWidth, @ASwapchainTextureHeight));
end;

procedure TSdlGpuCommandBuffer.PushVertexUniformData(const ASlotIndex: Integer;
  const AData: TBytes);
begin
  SDL_PushGPUVertexUniformData(FHandle, ASlotIndex, AData, Length(AData));
end;

{ TSdlGpuRenderPass }

procedure TSdlGpuRenderPass.BindFragmentSamplers(const AFirstSlot: Integer;
  const ATextureSamplerBindings: TArray<TSdlGpuTextureSamplerBinding>);
begin
  SDL_BindGPUFragmentSamplers(FHandle, AFirstSlot, Pointer(ATextureSamplerBindings),
    Length(ATextureSamplerBindings));
end;

procedure TSdlGpuRenderPass.BindFragmentStorageBuffers(
  const AFirstSlot: Integer; const AStorageBuffers: TArray<TSdlGpuBuffer>);
begin
  SDL_BindGPUFragmentStorageBuffers(FHandle, AFirstSlot, Pointer(AStorageBuffers),
    Length(AStorageBuffers));
end;

procedure TSdlGpuRenderPass.BindFragmentStorageTextures(
  const AFirstSlot: Integer; const AStorageTextures: TArray<TSdlGpuTexture>);
begin
  SDL_BindGPUFragmentStorageTextures(FHandle, AFirstSlot, Pointer(AStorageTextures),
    Length(AStorageTextures));
end;

procedure TSdlGpuRenderPass.BindIndexBuffer(
  const ABinding: TSdlGpuBufferBinding;
  const AIndexElementSize: TSdlGpuIndexElementSize);
begin
  SDL_BindGPUIndexBuffer(FHandle, @ABinding.FHandle, Ord(AIndexElementSize));
end;

procedure TSdlGpuRenderPass.BindPipeline(
  const AGraphicsPipeline: TSdlGpuGraphicsPipeline);
begin
  SDL_BindGPUGraphicsPipeline(FHandle, AGraphicsPipeline.FHandle);
end;

procedure TSdlGpuRenderPass.BindVertexBuffers(const AFirstSlot: Integer;
  const ABindings: TArray<TSdlGpuBufferBinding>);
begin
  SDL_BindGPUVertexBuffers(FHandle, AFirstSlot, Pointer(ABindings), Length(ABindings));
end;

procedure TSdlGpuRenderPass.BindVertexSamplers(const AFirstSlot: Integer;
  const ATextureSamplerBindings: TArray<TSdlGpuTextureSamplerBinding>);
begin
  SDL_BindGPUVertexSamplers(FHandle, AFirstSlot, Pointer(ATextureSamplerBindings),
    Length(ATextureSamplerBindings));
end;

procedure TSdlGpuRenderPass.BindVertexStorageBuffers(const AFirstSlot: Integer;
  const AStorageBuffers: TArray<TSdlGpuBuffer>);
begin
  SDL_BindGPUVertexStorageBuffers(FHandle, AFirstSlot, Pointer(AStorageBuffers),
    Length(AStorageBuffers));
end;

procedure TSdlGpuRenderPass.BindVertexStorageTextures(const AFirstSlot: Integer;
  const AStorageTextures: TArray<TSdlGpuTexture>);
begin
  SDL_BindGPUVertexStorageTextures(FHandle, AFirstSlot, Pointer(AStorageTextures),
    Length(AStorageTextures));
end;

procedure TSdlGpuRenderPass.DrawPrimitives(const ANumVertices, ANumInstances,
  AFirstVertex, AFirstInstance: Integer);
begin
  SDL_DrawGPUPrimitives(FHandle, ANumVertices, ANumInstances, AFirstVertex, AFirstInstance);
end;

procedure TSdlGpuRenderPass.DrawIndexedPrimitives(const ANumIndices,
  ANumInstances, AFirstIndex, AVertexOffset, AFirstInstance: Integer);
begin
  SDL_DrawGPUIndexedPrimitives(FHandle, ANumIndices, ANumInstances, AFirstIndex,
    AVertexOffset, AFirstInstance);
end;

procedure TSdlGpuRenderPass.DrawIndexedPrimitives(const ABuffer: TSdlGpuBuffer;
  const AOffset, ADrawCount: Integer);
begin
  SDL_DrawGPUIndexedPrimitivesIndirect(FHandle, ABuffer.FHandle, AOffset, ADrawCount);
end;

procedure TSdlGpuRenderPass.DrawPrimitives(const ABuffer: TSdlGpuBuffer;
  const AOffset, ADrawCount: Integer);
begin
  SDL_DrawGPUPrimitivesIndirect(FHandle, ABuffer.FHandle, AOffset, ADrawCount);
end;

class operator TSdlGpuRenderPass.Equal(const ALeft,
  ARight: TSdlGpuRenderPass): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuRenderPass.Equal(const ALeft: TSdlGpuRenderPass;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlGpuRenderPass.Finish;
begin
  SDL_EndGPURenderPass(FHandle);
  FHandle := 0;
end;

class operator TSdlGpuRenderPass.Implicit(const AValue: Pointer): TSdlGpuRenderPass;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuRenderPass.NotEqual(const ALeft,
  ARight: TSdlGpuRenderPass): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuRenderPass.NotEqual(const ALeft: TSdlGpuRenderPass;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlGpuRenderPass.SetBlendConstants(
  const ABlendConstants: TSdlColorF);
begin
  SDL_SetGPUBlendConstants(FHandle, SDL_FColor(ABlendConstants));
end;

procedure TSdlGpuRenderPass.SetScissor(const AScissor: TSdlRect);
begin
  SDL_SetGPUScissor(FHandle, @AScissor);
end;

procedure TSdlGpuRenderPass.SetStencilReference(const AReference: Byte);
begin
  SDL_SetGPUStencilReference(FHandle, AReference);
end;

procedure TSdlGpuRenderPass.SetViewport(const AViewport: TSdlGpuViewport);
begin
  SDL_SetGPUViewport(FHandle, @AViewport);
end;

{ TSdlGpuComputePass }

procedure TSdlGpuComputePass.BindPipeline(
  const AComputePipeline: TSdlGpuComputePipeline);
begin
  SDL_BindGPUComputePipeline(FHandle, AComputePipeline.FHandle);
end;

procedure TSdlGpuComputePass.BindSamplers(const AFirstSlot: Integer;
  const ATextureSamplerBindings: TArray<TSdlGpuTextureSamplerBinding>);
begin
  SDL_BindGPUComputeSamplers(FHandle, AFirstSlot, Pointer(ATextureSamplerBindings),
    Length(ATextureSamplerBindings));
end;

procedure TSdlGpuComputePass.BindStorageBuffers(const AFirstSlot: Integer;
  const AStorageBuffers: TArray<TSdlGpuBuffer>);
begin
  SDL_BindGPUComputeStorageBuffers(FHandle, AFirstSlot, Pointer(AStorageBuffers),
    Length(AStorageBuffers));
end;

procedure TSdlGpuComputePass.BindStorageTextures(const AFirstSlot: Integer;
  const AStorageTextures: TArray<TSdlGpuTexture>);
begin
  SDL_BindGPUComputeStorageTextures(FHandle, AFirstSlot, Pointer(AStorageTextures),
    Length(AStorageTextures));
end;

procedure TSdlGpuComputePass.Dispatch(const ABuffer: TSdlGpuBuffer;
  const AOffset: Integer);
begin
  SDL_DispatchGPUComputeIndirect(FHandle, ABuffer.FHandle, AOffset);
end;

class operator TSdlGpuComputePass.Equal(const ALeft,
  ARight: TSdlGpuComputePass): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlGpuComputePass.Dispatch(const AGroupCountX, AGroupCountY,
  AGroupCountZ: Integer);
begin
  SDL_DispatchGPUCompute(FHandle, AGroupCountX, AGroupCountY, AGroupCountZ);
end;

class operator TSdlGpuComputePass.Equal(const ALeft: TSdlGpuComputePass;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlGpuComputePass.Finish;
begin
  SDL_EndGPUComputePass(FHandle);
  FHandle := 0;
end;

class operator TSdlGpuComputePass.Implicit(const AValue: Pointer): TSdlGpuComputePass;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuComputePass.NotEqual(const ALeft,
  ARight: TSdlGpuComputePass): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuComputePass.NotEqual(const ALeft: TSdlGpuComputePass;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGpuCopyPass }

procedure TSdlGpuCopyPass.CopyBufferToBuffer(const ASource,
  ADestination: TSdlGpuBufferLocation; const ASize: Integer;
  const ACycle: Boolean);
begin
  SDL_CopyGPUBufferToBuffer(FHandle, @ASource.FHandle, @ADestination.FHandle,
    ASize, ACycle);
end;

procedure TSdlGpuCopyPass.CopyTextureToTexture(const ASource,
  ADestination: TSdlGpuTextureLocation; const AW, AH, AD: Integer;
  const ACycle: Boolean);
begin
  SDL_CopyGPUTextureToTexture(FHandle, @ASource.FHandle, @ADestination.FHandle,
    AW, AH, AD, ACycle);
end;

procedure TSdlGpuCopyPass.DownloadFromBuffer(const ASource: TSdlGpuBufferRegion;
  const ADestination: TSdlGpuTransferBufferLocation);
begin
  SDL_DownloadFromGPUBuffer(FHandle, @ASource.FHandle, @ADestination.FHandle);
end;

procedure TSdlGpuCopyPass.DownloadFromTexture(
  const ASource: TSdlGpuTextureRegion;
  const ADestination: TSdlGpuTextureTransferInfo);
begin
  SDL_DownloadFromGPUTexture(FHandle, @ASource.FHandle, @ADestination.FHandle);
end;

class operator TSdlGpuCopyPass.Equal(const ALeft,
  ARight: TSdlGpuCopyPass): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuCopyPass.Equal(const ALeft: TSdlGpuCopyPass;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlGpuCopyPass.Finish;
begin
  SDL_EndGPUCopyPass(FHandle);
  FHandle := 0;
end;

class operator TSdlGpuCopyPass.Implicit(const AValue: Pointer): TSdlGpuCopyPass;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuCopyPass.NotEqual(const ALeft,
  ARight: TSdlGpuCopyPass): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuCopyPass.NotEqual(const ALeft: TSdlGpuCopyPass;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlGpuCopyPass.UploadToBuffer(
  const ASource: TSdlGpuTransferBufferLocation;
  const ADestination: TSdlGpuBufferRegion; const ACycle: Boolean);
begin
  SDL_UploadToGPUBuffer(FHandle, @ASource.FHandle, @ADestination.FHandle, ACycle);
end;

procedure TSdlGpuCopyPass.UploadToTexture(
  const ASource: TSdlGpuTextureTransferInfo;
  const ADestination: TSdlGpuTextureRegion; const ACycle: Boolean);
begin
  SDL_UploadToGPUTexture(FHandle, @ASource.FHandle, @ADestination.FHandle, ACycle);
end;

{ TSdlGpuFence }

class operator TSdlGpuFence.Equal(const ALeft: TSdlGpuFence;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGpuFence.Equal(const ALeft, ARight: TSdlGpuFence): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGpuFence.Implicit(const AValue: Pointer): TSdlGpuFence;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlGpuFence.NotEqual(const ALeft,
  ARight: TSdlGpuFence): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGpuFence.NotEqual(const ALeft: TSdlGpuFence;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

end.

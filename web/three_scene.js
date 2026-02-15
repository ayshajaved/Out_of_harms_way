let scene, camera, renderer, liquidSphere, starField;
let clock = new THREE.Clock();

function initThreeScene() {
    const container = document.getElementById('three-container');
    if (!container) return;

    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.z = 3;

    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    container.appendChild(renderer.domElement);

    // Liquid Sphere
    const geometry = new THREE.IcosahedronGeometry(1.4, 4);
    // Store original positions for displacement
    geometry.userData.originalPositions = JSON.parse(JSON.stringify(geometry.attributes.position.array));

    const material = new THREE.MeshStandardMaterial({
        color: 0xE8C1CF,
        roughness: 0.05,
        metalness: 0.95,
        emissive: 0x882244,
        emissiveIntensity: 0.6,
        flatShading: false,
    });

    liquidSphere = new THREE.Mesh(geometry, material);
    scene.add(liquidSphere);

    // Starfield
    const particlesGeometry = new THREE.BufferGeometry();
    const positions = [];
    for (let i = 0; i < 3000; i++) {
        positions.push((Math.random() - 0.5) * 15);
        positions.push((Math.random() - 0.5) * 15);
        positions.push((Math.random() - 0.5) * 15);
    }
    particlesGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));

    const particlesMaterial = new THREE.PointsMaterial({
        size: 0.02,
        color: 0xFFFFFF,
        transparent: true,
        opacity: 0.6,
        blending: THREE.AdditiveBlending,
    });

    starField = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(starField);

    // Lights
    const ambientLight = new THREE.AmbientLight(0xFFFFFF, 0.4);
    scene.add(ambientLight);

    const dirLight1 = new THREE.DirectionalLight(0xFFF0FF, 1.5);
    dirLight1.position.set(5, 5, 5);
    scene.add(dirLight1);

    const pointLight = new THREE.PointLight(0xE8C1CF, 2, 10);
    pointLight.position.set(2, 2, 2);
    scene.add(pointLight);

    // Interaction variables
    window.sphereRotationSpeed = { x: 0.001, y: 0.002 };
    window.targetScale = 1.0;
    window.targetPosition = { x: 0, y: 0 };

    animate();

    window.addEventListener('resize', onWindowResize, false);
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

function animate() {
    requestAnimationFrame(animate);

    const time = clock.getElapsedTime();

    // Rotation based on hand input or default idle
    liquidSphere.rotation.y += window.sphereRotationSpeed.y;
    liquidSphere.rotation.x += window.sphereRotationSpeed.x;
    starField.rotation.y += 0.0005;

    // Smooth scaling
    liquidSphere.scale.lerp(new THREE.Vector3(window.targetScale, window.targetScale, window.targetScale), 0.1);

    // Position following hand (with floating overlay)
    liquidSphere.position.x += (window.targetPosition.x - liquidSphere.position.x) * 0.1;
    // Y position combines hand target + floating sine wave
    const floatY = Math.sin(time * 0.5) * 0.2;
    liquidSphere.position.y += ((window.targetPosition.y + floatY) - liquidSphere.position.y) * 0.1;

    // Liquid displacement effect
    const positions = liquidSphere.geometry.attributes.position.array;
    const originalPositions = liquidSphere.geometry.userData.originalPositions;
    // Use current scale for displacement calculation base to avoid artifacts
    const currentScale = liquidSphere.scale.x;

    for (let i = 0; i < positions.length; i += 3) {
        const ox = originalPositions[i];
        const oy = originalPositions[i + 1];
        const oz = originalPositions[i + 2];

        // Complex wave motion
        const displacement = Math.sin(ox * 2.0 + time * 1.5) *
            Math.cos(oy * 2.0 + time * 2.0) *
            Math.sin(oz * 2.0 + time * 1.5) * 0.4;

        // Apply scale AND displacement
        const scaleFactor = 1 + displacement * 0.3;
        positions[i] = ox * scaleFactor;
        positions[i + 1] = oy * scaleFactor;
        positions[i + 2] = oz * scaleFactor;
    }
    liquidSphere.geometry.attributes.position.needsUpdate = true;
    liquidSphere.geometry.computeVertexNormals();

    renderer.render(scene, camera);
}

// Exposed function for Flutter
// Exposed functions for Flutter/JS
window.updateSphereScale = function (scale) {
    window.targetScale = scale;
}

window.updateSphereRotation = function (speedX, speedY) {
    window.sphereRotationSpeed.x = speedX;
    window.sphereRotationSpeed.y = speedY;
}

window.updateSpherePosition = function (x, y) {
    // Map -1 to 1 range to scene coordinates (approx -4 to 4)
    window.targetPosition.x = x * 4;
    window.targetPosition.y = y * 3;
}

// Initial call when DOM is ready
window.addEventListener('DOMContentLoaded', initThreeScene);
